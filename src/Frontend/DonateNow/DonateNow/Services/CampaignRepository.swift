import Foundation
import Supabase

class CampaignRepository {
    private let supabase = SupabaseManager.shared.client
    
    private struct CreateCampaignRequest: Encodable {
        let creator_id: String
        let title: String
        let description: String
        let category: String?
        let target_amount: String
        let image_url: String?
    }
    
    // Create a new campaign (draft status by default)
    func createCampaign(
        creatorId: UUID,
        title: String,
        description: String,
        category: String?,
        targetAmount: Decimal,
        imageUrl: String?
    ) async throws -> DonationProfile {
        let req = CreateCampaignRequest(
            creator_id: creatorId.uuidString,
            title: title,
            description: description,
            category: category,
            target_amount: targetAmount.description,
            image_url: imageUrl
        )
        
        let profile: DonationProfile = try await supabase
            .from("donation_profiles")
            .insert(req)
            .select()
            .single()
            .execute()
            .value
            
        return profile
    }
    
    private struct UpdateCampaignRequest: Encodable {
        var title: String?
        var description: String?
        var target_amount: String?
        var image_url: String?
        var verification_status: String?
    }
    
    // Update an existing campaign
    func updateCampaign(
        id: UUID,
        title: String?,
        description: String?,
        targetAmount: Decimal?,
        imageUrl: String?
    ) async throws {
        var req = UpdateCampaignRequest()
        if let title = title { req.title = title }
        if let description = description { req.description = description }
        if let targetAmount = targetAmount { req.target_amount = targetAmount.description }
        if let imageUrl = imageUrl { req.image_url = imageUrl }
        
        // Material changes reset verification to pending
        req.verification_status = "pending"
        
        try await supabase
            .from("donation_profiles")
            .update(req)
            .eq("id", value: id.uuidString)
            .execute()
    }
    
    // Fetch campaigns for a specific creator
    func getCampaignsForCreator(creatorId: UUID) async throws -> [DonationProfile] {
        let profiles: [DonationProfile] = try await supabase
            .from("donation_profiles")
            .select()
            .eq("creator_id", value: creatorId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        return profiles
    }
}
