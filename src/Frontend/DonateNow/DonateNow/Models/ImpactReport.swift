import Foundation

struct ImpactReport: Codable, Identifiable {
    let id: UUID
    let campaignId: UUID
    let content: String
    // We can use a raw string or a Codable struct for JSONB
    let statisticsJson: String?
    let dateRangeStart: Date
    let dateRangeEnd: Date
    let generatedAt: Date
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case campaignId = "campaign_id"
        case content
        case statisticsJson = "statistics_json"
        case dateRangeStart = "date_range_start"
        case dateRangeEnd = "date_range_end"
        case generatedAt = "generated_at"
        case createdAt = "created_at"
    }
}
