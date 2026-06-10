import Foundation
import SwiftUI
import Supabase

@MainActor
class DonationViewModel: ObservableObject {
    private let client = SupabaseManager.shared.client
    
    @Published var activeCause: Cause?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Form Inputs
    @Published var donorName = ""
    @Published var donorEmail = ""
    @Published var donorPhone = ""
    @Published var donationAmount = ""
    @Published var customAmount = ""
    
    // Flow States
    @Published var selectedAmount: Double? = 500
    @Published var verificationResult: PaymentVerificationResponse?
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
    
    struct VerifyPaymentRequest: Codable {
        let razorpay_order_id: String
        let razorpay_payment_id: String
        let razorpay_signature: String
        let donor_name: String
        let donor_email: String
        let donor_phone: String
        let amount: Double
        let cause_id: UUID
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
    
    func fetchActiveCause() async {
        isLoading = true
        errorMessage = nil
        do {
            let causes: [Cause] = try await client
                .from("causes")
                .select()
                .eq("is_active", true)
                .execute()
                .value
            
            self.activeCause = causes.first
        } catch {
            self.errorMessage = "Failed to load causes: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func initiateDonation() async {
        guard isFormValid, let cause = activeCause else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Create order on server side
            let orderRequest = CreateOrderRequest(amount: finalAmount, currency: "INR")
            let orderResponse: CreateOrderResponse = try await client.functions.invoke(
                "create-order",
                options: FunctionInvokeOptions(body: orderRequest)
            )
            
            // 2. Present Razorpay Payment Sheet
            PaymentService.shared.presentPaymentSheet(
                amount: finalAmount,
                orderId: orderResponse.order_id,
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
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    private func verifyPayment(_ result: RazorpayResult) async {
        guard let cause = activeCause else { return }
        do {
            let verifyRequest = VerifyPaymentRequest(
                razorpay_order_id: result.orderId,
                razorpay_payment_id: result.paymentId,
                razorpay_signature: result.signature,
                donor_name: donorName,
                donor_email: donorEmail,
                donor_phone: donorPhone,
                amount: finalAmount,
                cause_id: cause.id
            )
            
            let verification: PaymentVerificationResponse = try await client.functions.invoke(
                "verify-payment",
                options: FunctionInvokeOptions(body: verifyRequest)
            )
            
            if verification.success {
                self.verificationResult = verification
                // Reset form
                self.donorName = ""
                self.donorEmail = ""
                self.donorPhone = ""
                self.customAmount = ""
                self.selectedAmount = 500
                self.isThankYouActive = true
            } else {
                self.errorMessage = "Payment verification failed."
            }
        } catch {
            self.errorMessage = "Verification error: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
