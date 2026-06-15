import Foundation

struct CampaignProgress: Codable, Identifiable {
    let id: UUID
    let campaignId: UUID
    let totalRaised: Decimal
    let totalDonors: Int
    let percentage: Decimal
    let snapshotDate: Date
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case campaignId = "campaign_id"
        case totalRaised = "total_raised"
        case totalDonors = "total_donors"
        case percentage
        case snapshotDate = "snapshot_date"
        case createdAt = "created_at"
    }
}
