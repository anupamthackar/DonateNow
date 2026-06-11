import Testing
import Foundation
import Supabase
@testable import DonateNow

struct IntegrationTests {
    private let client = SupabaseManager.shared.client

    @Test func testSupabaseConnectionAndFetchCauses() async throws {
        // Query active causes anonymously
        let causes: [Cause] = try await client
            .from("causes")
            .select()
            .eq("is_active", value: true)
            .execute()
            .value
            
        // We know we have at least one active cause in our remote database
        #expect(!causes.isEmpty)
        if let first = causes.first {
            #expect(!first.title.isEmpty)
            #expect(first.targetAmount > 0)
        }
    }
    
    @Test func testCreateOrderEdgeFunction() async throws {
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

        let orderRequest = CreateOrderRequest(amount: 500, currency: "INR")
        
        do {
            let orderResponse: CreateOrderResponse = try await client.functions.invoke(
                "create-order",
                options: FunctionInvokeOptions(body: orderRequest)
            )
            #expect(!orderResponse.order_id.isEmpty)
            #expect(orderResponse.amount == 50000)
            #expect(orderResponse.currency == "INR")
            #expect(!orderResponse.key_id.isEmpty)
        } catch {
            Issue.record("Failed to invoke create-order edge function: \(error.localizedDescription)")
        }
    }
    
    @Test func testVerifyPaymentEdgeFunctionRejection() async throws {
        struct VerifyPaymentRequest: Codable {
            let razorpay_order_id: String
            let razorpay_payment_id: String
            let razorpay_signature: String
            let donor_name: String
            let donor_email: String
            let donor_phone: String
            let amount: Double
            let cause_id: UUID?
        }
        
        // Use intentionally invalid signature to test payment verification failure path
        let verifyRequest = VerifyPaymentRequest(
            razorpay_order_id: "order_mock123",
            razorpay_payment_id: "pay_mock123",
            razorpay_signature: "invalid_signature_hash_xyz",
            donor_name: "Test User",
            donor_email: "test@example.com",
            donor_phone: "9876543210",
            amount: 500.0,
            cause_id: nil
        )
        
        do {
            let _: DonationViewModel.PaymentVerificationResponse = try await client.functions.invoke(
                "verify-payment",
                options: FunctionInvokeOptions(body: verifyRequest)
            )
            Issue.record("verify-payment should have failed with invalid signature, but succeeded!")
        } catch {
            // Expect failure due to signature mismatch
            if let functionsError = error as? FunctionsError {
                switch functionsError {
                case .httpError(let code, let data):
                    #expect(code == 400)
                    if let errorObj = try? JSONDecoder().decode([String: String].self, from: data),
                       let serverMessage = errorObj["error"] {
                        #expect(serverMessage.contains("verification") || serverMessage.contains("signature") || serverMessage.contains("failed") || serverMessage.contains("Invalid"))
                    }
                default:
                    Issue.record("Unexpected FunctionsError type: \(functionsError)")
                }
            } else {
                Issue.record("Unexpected error: \(error.localizedDescription)")
            }
        }
    }
}
