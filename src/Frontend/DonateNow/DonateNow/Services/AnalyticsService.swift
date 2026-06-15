import Foundation
import Supabase

class AnalyticsService {
    private let supabase = SupabaseManager.shared.client
    
    // Fetch stats via the RPC we created in Phase 1
    func getCampaignStats(campaignId: UUID) async throws -> CampaignStats {
        let response: String = try await supabase
            .rpc("get_campaign_stats", params: ["p_campaign_id": campaignId.uuidString])
            .execute()
            .value
            
        // Decode the JSON string returned by RPC
        guard let data = response.data(using: .utf8) else {
            throw AppError.decodingError
        }
        
        return try JSONDecoder().decode(CampaignStats.self, from: data)
    }
    
    func getPlatformStats() async throws -> PlatformStats {
        let response: String = try await supabase
            .rpc("get_platform_stats")
            .execute()
            .value
            
        guard let data = response.data(using: .utf8) else {
            throw AppError.decodingError
        }
        
        return try JSONDecoder().decode(PlatformStats.self, from: data)
    }
}

// Stats Models
struct CampaignStats: Codable {
    let totalRaised: Decimal
    let totalDonors: Int
    let totalDonations: Int
    let avgDonation: Decimal
    let latestDonation: Date?
    
    enum CodingKeys: String, CodingKey {
        case totalRaised = "total_raised"
        case totalDonors = "total_donors"
        case totalDonations = "total_donations"
        case avgDonation = "avg_donation"
        case latestDonation = "latest_donation"
    }
}

struct PlatformStats: Codable {
    let totalCampaigns: Int
    let verifiedCampaigns: Int
    let pendingVerifications: Int
    let totalDonations: Int
    let totalRaised: Decimal
    let totalSubscribers: Int
    let totalUsers: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCampaigns = "total_campaigns"
        case verifiedCampaigns = "verified_campaigns"
        case pendingVerifications = "pending_verifications"
        case totalDonations = "total_donations"
        case totalRaised = "total_raised"
        case totalSubscribers = "total_subscribers"
        case totalUsers = "total_users"
    }
}
