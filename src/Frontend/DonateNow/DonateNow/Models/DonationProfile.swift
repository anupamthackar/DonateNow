import Foundation

struct DonationProfile: Codable, Identifiable {
    let id: UUID
    let creatorId: UUID
    let title: String
    let description: String
    let category: String?
    let targetAmount: Decimal
    var raisedAmount: Decimal
    let imageUrl: String?
    let verificationStatus: VerificationStatus
    let isActive: Bool
    let startDate: Date
    let endDate: Date?
    let createdAt: Date
    let updatedAt: Date
    
    // Joined data from users table
    struct JoinedUser: Codable {
        let name: String
    }
    var users: JoinedUser?
    
    var creatorName: String? {
        return users?.name
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorId = "creator_id"
        case title
        case description
        case category
        case targetAmount = "target_amount"
        case raisedAmount = "raised_amount"
        case imageUrl = "image_url"
        case verificationStatus = "verification_status"
        case isActive = "is_active"
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case users
    }
}

enum VerificationStatus: String, Codable {
    case draft
    case pending
    case verified
    case rejected
    case suspended
}
