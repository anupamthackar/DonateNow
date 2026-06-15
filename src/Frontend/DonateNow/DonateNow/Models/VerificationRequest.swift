import Foundation

struct VerificationRequest: Codable, Identifiable {
    let id: UUID
    let campaignId: UUID
    let documentsUrl: [String]
    let status: VerificationStatus
    let reviewerId: UUID?
    let reviewNotes: String?
    let submittedAt: Date
    let reviewedAt: Date?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case campaignId = "campaign_id"
        case documentsUrl = "documents_url"
        case status
        case reviewerId = "reviewer_id"
        case reviewNotes = "review_notes"
        case submittedAt = "submitted_at"
        case reviewedAt = "reviewed_at"
        case createdAt = "created_at"
    }
}
