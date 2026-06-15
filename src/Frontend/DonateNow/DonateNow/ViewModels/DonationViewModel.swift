import Foundation
import Combine
import SwiftUI
import Supabase

@MainActor
class DonationViewModel: ObservableObject {
    private let client = SupabaseManager.shared.client
    
    @Published var activeCause: DonationProfile?
    private var activeCauseIsMock = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Form Inputs
    @Published var donorName = ""
    @Published var donorEmail = ""
    @Published var donorPhone = ""
    @Published var isAnonymous = false
    @Published var isRecurring = false
    
    // UI State
    @Published var donationAmount = ""
    @Published var customAmount = ""
    
    // Flow States
    @Published var selectedAmount: Double? = 500
    @Published var verificationResult: PaymentVerificationResponse?
    @Published var completedAmount: Double = 0.0
    @Published var isThankYouActive = false
    
    struct CreateOrderRequest: Codable {
        let amount: Double
        let currency: String
    }
    
    struct CreateOrderResponse: Codable {
        let order_id: String
        let amount: Double
        let currency: String
        let key_id: String
    }
    
    struct CreateSubscriptionRequest: Codable {
        let campaignId: String
        let amount: Double
        let frequency: String
    }
    
    struct CreateSubscriptionResponse: Codable {
        let subscriptionId: String
        let dbId: String
    }
    
    struct VerifyPaymentRequest: Codable {
        let razorpay_order_id: String?
        let razorpay_subscription_id: String?
        let razorpay_payment_id: String
        let razorpay_signature: String
        let donor_name: String
        let donor_email: String
        let donor_phone: String
        let amount: Double
        let campaign_id: UUID?
        let is_anonymous: Bool
        let is_recurring: Bool
    }
    
    struct PaymentVerificationResponse: Codable {
        let success: Bool
        let donation_id: UUID
    }
    
    var finalAmount: Double {
        if let selected = selectedAmount {
            return selected
        }
        return Double(customAmount) ?? 0
    }
    
    var isFormValid: Bool {
        guard !donorName.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        guard Validators.isValidEmail(donorEmail) else { return false }
        guard Validators.isValidPhone(donorPhone) else { return false }
        
        let amount = finalAmount
        return amount >= 1 && amount <= 100000
    }
    
    func fetchCause(id: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            let profiles: [DonationProfile] = try await client
                .from("donation_profiles")
                .select()
                .eq("id", value: id)
                .execute()
                .value
            
            if let firstProfile = profiles.first {
                self.activeCause = firstProfile
                self.activeCauseIsMock = false
            } else {
                print("DEBUG - fetchCause: No donation_profiles found in database for id \(id).")
                injectMockCause()
            }
        } catch {
            print("DEBUG - Supabase fetch failed: \(error.localizedDescription)")
            if let functionsError = error as? FunctionsError {
                print("DEBUG - Supabase fetch FunctionsError: \(functionsError)")
            }
            injectMockCause()
        }
        isLoading = false
    }
    
    private func injectMockCause() {
        self.activeCause = DonationProfile(
            id: UUID(),
            creatorId: UUID(),
            title: "Help Educate Underprivileged Children",
            description: "Your donation will provide books, uniforms, and tuition for children in rural areas who do not have access to quality education. Join us in building a better future!",
            category: "Education",
            targetAmount: 500000.0,
            raisedAmount: 12500.0,
            imageUrl: "https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?q=80&w=2070&auto=format&fit=crop",
            verificationStatus: .verified,
            isActive: true,
            startDate: Date(),
            endDate: nil,
            createdAt: Date(),
            updatedAt: Date(),
            users: DonationProfile.JoinedUser(name: "Mock NGO")
        )
        self.activeCauseIsMock = true
    }
    
    func initiateDonation() async {
        guard isFormValid, let cause = activeCause else { return }
        
        // Prevent anonymous recurring donations
        if isRecurring && AuthService.shared.session == nil {
            errorMessage = "You must be logged in to set up a monthly donation."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var orderId: String? = nil
            var subscriptionId: String? = nil
            
            if isRecurring {
                // Subscription Flow
                do {
                    let subRequest = CreateSubscriptionRequest(
                        campaignId: cause.id.uuidString,
                        amount: finalAmount,
                        frequency: "monthly"
                    )
                    let subResponse: CreateSubscriptionResponse = try await client.functions.invoke(
                        "create-subscription",
                        options: FunctionInvokeOptions(body: subRequest)
                    )
                    subscriptionId = subResponse.subscriptionId
                } catch {
                    if let functionsError = error as? FunctionsError {
                        switch functionsError {
                        case .httpError(let code, let data):
                            if let errorObj = try? JSONDecoder().decode([String: String].self, from: data),
                               let serverMessage = errorObj["error"] {
                                self.errorMessage = "Failed to create subscription: \(serverMessage)"
                                print("DEBUG - create-subscription HTTP error: \(serverMessage)")
                            } else if let rawString = String(data: data, encoding: .utf8) {
                                self.errorMessage = "Failed to create subscription: \(rawString)"
                            } else {
                                self.errorMessage = "Failed to create subscription HTTP error: \(code)"
                            }
                        case .relayError:
                            self.errorMessage = "Relay error: network issue between client and Supabase"
                        }
                    } else {
                        self.errorMessage = "Failed to create subscription: \(error.localizedDescription)"
                    }
                    self.isLoading = false
                    return
                }
            } else {
                // One-time Order Flow
                orderId = "order_mock_12345" // Fallback mock
                do {
                    let orderRequest = CreateOrderRequest(amount: finalAmount, currency: "INR")
                    let orderResponse: CreateOrderResponse = try await client.functions.invoke(
                        "create-order",
                        options: FunctionInvokeOptions(body: orderRequest)
                    )
                    orderId = orderResponse.order_id
                } catch {
                    print("DEBUG - Edge function 'create-order' failed: \(error.localizedDescription). Falling back to mock orderId.")
                }
            }
            
            // 2. Present Razorpay Payment Sheet
            PaymentService.shared.presentPaymentSheet(
                amount: finalAmount,
                orderId: orderId,
                subscriptionId: subscriptionId,
                description: cause.title,
                donorName: donorName,
                donorEmail: donorEmail,
                donorPhone: donorPhone
            ) { [weak self] result in
                guard let self = self else { return }
                
                Task { @MainActor in
                    switch result {
                    case .success(let razorpayResult):
                        await self.verifyPayment(razorpayResult)
                    case .failure(let error):
                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func verifyPayment(_ result: RazorpayResult) async {
        guard let cause = activeCause else { return }
        do {
            let verifyRequest = VerifyPaymentRequest(
                razorpay_order_id: result.orderId,
                razorpay_subscription_id: result.subscriptionId,
                razorpay_payment_id: result.paymentId,
                razorpay_signature: result.signature,
                donor_name: donorName,
                donor_email: donorEmail,
                donor_phone: donorPhone,
                amount: finalAmount,
                campaign_id: activeCauseIsMock ? nil : cause.id,
                is_anonymous: isAnonymous,
                is_recurring: isRecurring
            )
            
            let verification: PaymentVerificationResponse = try await client.functions.invoke(
                "verify-payment",
                options: FunctionInvokeOptions(body: verifyRequest)
            )
            
            if verification.success {
                self.completedAmount = finalAmount
                self.verificationResult = verification
                // Reset form
                self.donorName = ""
                self.donorEmail = ""
                self.donorPhone = ""
                self.customAmount = ""
                self.selectedAmount = 500
                self.isThankYouActive = true
                NotificationCenter.default.post(
                    name: .donationCompleted,
                    object: nil,
                    userInfo: ["amount": finalAmount, "causeId": cause.id]
                )
            } else {
                self.errorMessage = "Payment verification failed."
            }
        } catch {
            if let functionsError = error as? FunctionsError {
                switch functionsError {
                case .httpError(let code, let data):
                    if let errorObj = try? JSONDecoder().decode([String: String].self, from: data),
                       let serverMessage = errorObj["error"] {
                        self.errorMessage = "Verification error (\(code)): \(serverMessage)"
                    } else if let rawString = String(data: data, encoding: .utf8) {
                        self.errorMessage = "Verification error (\(code)): \(rawString)"
                    } else {
                        self.errorMessage = "Verification HTTP error: \(code)"
                    }
                case .relayError:
                    self.errorMessage = "Relay error: network issue between client and Supabase"
                }
            } else {
                self.errorMessage = "Verification error: \(error.localizedDescription)"
            }
        }
        isLoading = false
    }
}
