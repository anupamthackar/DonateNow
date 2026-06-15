import Foundation

struct PaymentLog: Codable, Identifiable {
    let id: UUID
    let donationId: UUID
    let eventType: String
    let amount: Decimal
    let status: String
    let razorpayEventId: String?
    let metadataJson: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case donationId = "donation_id"
        case eventType = "event_type"
        case amount
        case status
        case razorpayEventId = "razorpay_event_id"
        case metadataJson = "metadata_json"
        case createdAt = "created_at"
    }
}
