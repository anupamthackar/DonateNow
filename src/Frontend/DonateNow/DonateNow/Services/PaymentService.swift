import Foundation
import UIKit
import Razorpay

struct RazorpayResult {
    let paymentId: String
    let orderId: String
    let signature: String
}

class PaymentService: NSObject, ObservableObject {
    static let shared = PaymentService()
    
    private var razorpay: RazorpayCheckout?
    private var completion: ((Result<RazorpayResult, Error>) -> Void)?
    
    private override init() {
        super.init()
        // Initialize Razorpay with key ID
        self.razorpay = RazorpayCheckout.initWithKey(Constants.razorpayKeyID, andDelegateWithData: self)
    }
    
    func presentPaymentSheet(
        amount: Double,
        orderId: String,
        description: String,
        donorName: String,
        donorEmail: String,
        donorPhone: String,
        completion: @escaping (Result<RazorpayResult, Error>) -> Void
    ) {
        self.completion = completion
        
        let options: [String: Any] = [
            "amount": Int(amount * 100), // Razorpay expects amount in paise (sub-units)
            "currency": "INR",
            "name": "DonateNow NGO",
            "description": description,
            "order_id": orderId,
            "prefill": [
                "name": donorName,
                "email": donorEmail,
                "contact": donorPhone
            ],
            "theme": [
                "color": "#16a34a" // Matches Light Mode Primary Color (#16a34a)
            ]
        ]
        
        DispatchQueue.main.async {
            guard let rootVC = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: { $0.isKeyWindow })?.rootViewController else {
                completion(.failure(AppError.paymentError("Unable to find root view controller")))
                return
            }
            
            self.razorpay?.open(options, displayController: rootVC)
        }
    }
}

extension PaymentService: RazorpayPaymentCompletionProtocolWithData {
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        guard let order_id = response?["razorpay_order_id"] as? String,
              let signature = response?["razorpay_signature"] as? String else {
            completion?(.failure(AppError.paymentError("Invalid success response from Razorpay")))
            return
        }
        
        let result = RazorpayResult(paymentId: payment_id, orderId: order_id, signature: signature)
        completion?(.success(result))
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        completion?(.failure(AppError.paymentError(str)))
    }
}
