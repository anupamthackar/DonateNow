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
    let isRecurring: Bool?
    
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
        case isRecurring = "is_recurring"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.causeId = try container.decodeIfPresent(UUID.self, forKey: .causeId)
        self.donorName = try container.decode(String.self, forKey: .donorName)
        self.donorEmail = try container.decode(String.self, forKey: .donorEmail)
        self.donorPhone = try container.decodeIfPresent(String.self, forKey: .donorPhone)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.status = try container.decode(String.self, forKey: .status)
        self.razorpayOrderId = try container.decodeIfPresent(String.self, forKey: .razorpayOrderId)
        self.razorpayPaymentId = try container.decodeIfPresent(String.self, forKey: .razorpayPaymentId)
        self.razorpaySignature = try container.decodeIfPresent(String.self, forKey: .razorpaySignature)
        self.paymentMethod = try container.decodeIfPresent(String.self, forKey: .paymentMethod)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.isRecurring = try container.decodeIfPresent(Bool.self, forKey: .isRecurring)
        
        // Handle decimal mapping from either JSON numeric double or string
        if let doubleAmount = try? container.decode(Double.self, forKey: .amount) {
            self.amount = doubleAmount
        } else if let stringAmount = try? container.decode(String.self, forKey: .amount),
                  let parsedAmount = Double(stringAmount) {
            self.amount = parsedAmount
        } else {
            throw DecodingError.typeMismatch(
                Double.self,
                DecodingError.Context(
                    codingPath: container.codingPath + [CodingKeys.amount],
                    debugDescription: "Expected Double or decimal-representable String for amount"
                )
            )
        }
    }
}
