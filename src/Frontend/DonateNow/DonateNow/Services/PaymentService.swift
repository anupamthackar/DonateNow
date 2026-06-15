import Foundation
import UIKit
import Razorpay
import Combine


struct RazorpayResult {
    let paymentId: String
    let orderId: String?
    let subscriptionId: String?
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
        orderId: String? = nil,
        subscriptionId: String? = nil,
        description: String,
        donorName: String,
        donorEmail: String,
        donorPhone: String,
        completion: @escaping (Result<RazorpayResult, Error>) -> Void
    ) {
        self.completion = completion
        
        var options: [String: Any] = [
            "amount": Int(amount * 100), // Razorpay expects amount in paise (sub-units)
            "currency": "INR",
            "name": "DonateNow NGO",
            "description": description,
            "prefill": [
                "name": donorName,
                "email": donorEmail,
                "contact": donorPhone
            ],
            "theme": [
                "color": "#16a34a" // Matches Light Mode Primary Color (#16a34a)
            ]
        ]
        
        if let subId = subscriptionId {
            options["subscription_id"] = subId
        } else if let ordId = orderId {
            options["order_id"] = ordId
        }
        
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }),
                  var topController = window.rootViewController else {
                completion(.failure(AppError.paymentError("Unable to find root view controller")))
                return
            }
            
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            guard let razorpay = self.razorpay else {
                completion(.failure(AppError.paymentError("Razorpay SDK failed to initialize. Please check your RAZORPAY_KEY_ID.")))
                return
            }
            
            razorpay.open(options, displayController: topController)
        }
    }
}

extension PaymentService: RazorpayPaymentCompletionProtocolWithData {
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        let order_id = response?["razorpay_order_id"] as? String
        let sub_id = response?["razorpay_subscription_id"] as? String
        
        guard let signature = response?["razorpay_signature"] as? String else {
            completion?(.failure(AppError.paymentError("Invalid success response from Razorpay: missing signature")))
            return
        }
        
        let result = RazorpayResult(paymentId: payment_id, orderId: order_id, subscriptionId: sub_id, signature: signature)
        completion?(.success(result))
    }
    
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        completion?(.failure(AppError.paymentError(str)))
    }
}
