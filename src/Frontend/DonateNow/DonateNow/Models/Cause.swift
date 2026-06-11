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
    
    init(
        id: UUID,
        title: String,
        description: String,
        targetAmount: Double,
        raisedAmount: Double,
        imageUrl: String?,
        isActive: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.targetAmount = targetAmount
        self.raisedAmount = raisedAmount
        self.imageUrl = imageUrl
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.isActive = try container.decode(Bool.self, forKey: .isActive)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        
        // Handle decimal targetAmount from either JSON numeric double or string
        if let doubleTarget = try? container.decode(Double.self, forKey: .targetAmount) {
            self.targetAmount = doubleTarget
        } else if let stringTarget = try? container.decode(String.self, forKey: .targetAmount),
                  let parsedTarget = Double(stringTarget) {
            self.targetAmount = parsedTarget
        } else {
            throw DecodingError.typeMismatch(
                Double.self,
                DecodingError.Context(
                    codingPath: container.codingPath + [CodingKeys.targetAmount],
                    debugDescription: "Expected Double or decimal-representable String for targetAmount"
                )
            )
        }
        
        // Handle decimal raisedAmount from either JSON numeric double or string
        if let doubleRaised = try? container.decode(Double.self, forKey: .raisedAmount) {
            self.raisedAmount = doubleRaised
        } else if let stringRaised = try? container.decode(String.self, forKey: .raisedAmount),
                  let parsedRaised = Double(stringRaised) {
            self.raisedAmount = parsedRaised
        } else {
            throw DecodingError.typeMismatch(
                Double.self,
                DecodingError.Context(
                    codingPath: container.codingPath + [CodingKeys.raisedAmount],
                    debugDescription: "Expected Double or decimal-representable String for raisedAmount"
                )
            )
        }
    }
}
