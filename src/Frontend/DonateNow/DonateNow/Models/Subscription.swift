import Foundation

struct Subscription: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let campaignId: UUID
    let razorpaySubId: String
    let amount: Decimal
    let currency: String
    let frequency: String
    let status: SubscriptionStatus
    let nextChargeDate: Date?
    let retryCount: Int
    let createdAt: Date
    let updatedAt: Date
    let cancelledAt: Date?
    
    // Optional joined data
    var campaignTitle: String?
    var campaignImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case campaignId = "campaign_id"
        case razorpaySubId = "razorpay_sub_id"
        case amount
        case currency
        case frequency
        case status
        case nextChargeDate = "next_charge_date"
        case retryCount = "retry_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case cancelledAt = "cancelled_at"
    }
}

enum SubscriptionStatus: String, Codable {
    case active
    case paused
    case cancelled
    case expired
}
