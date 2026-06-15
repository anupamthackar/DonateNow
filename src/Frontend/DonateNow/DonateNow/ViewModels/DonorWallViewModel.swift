import Foundation
import Supabase
import Combine

struct PublicDonor: Identifiable, Codable {
    let id: UUID
    let amount: Double
    let currency: String
    let createdAt: Date
    // This comes from the joined `users` table or from `donor_name` column depending on the schema
    let donorName: String
    let isAnonymous: Bool
    let isRecurring: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case currency
        case createdAt = "created_at"
        case donorName = "donor_name"
        case isAnonymous = "is_anonymous"
        case isRecurring = "is_recurring"
    }
}

@MainActor
class DonorWallViewModel: ObservableObject {
    @Published var donors: [PublicDonor] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let client = SupabaseManager.shared.client
    
    func fetchDonors(for campaignId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // We fetch where campaign_id matches, and filter out anonymous records or just map them later
            // The query only gets successful donations
            let response: [PublicDonor] = try await client
                .from("donations")
                .select("id, amount, currency, created_at, donor_name, is_anonymous, is_recurring")
                .eq("campaign_id", value: campaignId)
                .eq("status", value: "completed")
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.donors = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
