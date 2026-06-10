import Foundation

struct Cause: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let targetAmount: Double
    var raisedAmount: Double
    let imageUrl: String?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case targetAmount = "target_amount"
        case raisedAmount = "raised_amount"
        case imageUrl = "image_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
