import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let name: String
    let phone: String?
    let role: UserRole
    let avatarUrl: String?
    let supabaseAuthId: UUID?
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case phone
        case role
        case avatarUrl = "avatar_url"
        case supabaseAuthId = "supabase_auth_id"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum UserRole: String, Codable {
    case donor
    case creator
    case admin
}
