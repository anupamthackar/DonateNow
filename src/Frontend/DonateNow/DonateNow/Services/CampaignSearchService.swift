import Foundation
import Supabase

class CampaignSearchService {
    private let supabase = SupabaseManager.shared.client
    
    // Standard select query with joined creator name
    private let selectQuery = "*, users(name)"
    
    // Fetch all active, verified campaigns
    func fetchDiscoverableCampaigns(limit: Int = 20, offset: Int = 0) async throws -> [DonationProfile] {
        return try await supabase
            .from("donation_profiles")
            .select(selectQuery)
            .eq("is_active", value: true)
            .eq("verification_status", value: "verified")
            .order("created_at", ascending: false)
            .range(from: offset, to: offset + limit - 1)
            .execute()
            .value
    }
    
    // Search campaigns by text (title or description)
    func searchCampaigns(query: String) async throws -> [DonationProfile] {
        guard !query.isEmpty else {
            return try await fetchDiscoverableCampaigns()
        }
        
        return try await supabase
            .from("donation_profiles")
            .select(selectQuery)
            .eq("is_active", value: true)
            .eq("verification_status", value: "verified")
            .or("title.ilike.*\(query)*,description.ilike.*\(query)*")
            .order("created_at", ascending: false)
            .limit(20)
            .execute()
            .value
    }
    
    // Filter campaigns by category
    func filterByCategory(category: String) async throws -> [DonationProfile] {
        return try await supabase
            .from("donation_profiles")
            .select(selectQuery)
            .eq("is_active", value: true)
            .eq("verification_status", value: "verified")
            .eq("category", value: category)
            .order("created_at", ascending: false)
            .limit(20)
            .execute()
            .value
    }
}
