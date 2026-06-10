import Foundation

struct Donation: Identifiable, Codable {
    let id: UUID
    let causeId: UUID?
    let donorName: String
    let donorEmail: String
    let donorPhone: String?
    let amount: Double
    let currency: String
    let status: String
    let razorpayOrderId: String?
    let razorpayPaymentId: String?
    let razorpaySignature: String?
    let paymentMethod: String?
    let notes: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case causeId = "cause_id"
        case donorName = "donor_name"
        case donorEmail = "donor_email"
        case donorPhone = "donor_phone"
        case amount
        case currency
        case status
        case razorpayOrderId = "razorpay_order_id"
        case razorpayPaymentId = "razorpay_payment_id"
        case razorpaySignature = "razorpay_signature"
        case paymentMethod = "payment_method"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
