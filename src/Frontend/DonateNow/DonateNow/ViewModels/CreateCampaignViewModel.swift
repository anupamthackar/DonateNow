import Foundation
import Combine
import Supabase

@MainActor
class CreateCampaignViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var category: String = "Education"
    @Published var targetAmount: String = ""
    @Published var isSubmitting: Bool = false
    @Published var errorMessage: String? = nil
    
    // Abstracting repository for testing
    var createCampaignAction: (UUID, String, String, String, Decimal, String?) async throws -> DonationProfile
    
    init(createCampaignAction: @escaping (UUID, String, String, String, Decimal, String?) async throws -> DonationProfile) {
        self.createCampaignAction = createCampaignAction
    }
    
    func submitCampaign() async -> Bool {
        guard !title.isEmpty else {
            errorMessage = "Title cannot be empty."
            return false
        }
        
        guard !description.isEmpty else {
            errorMessage = "Description cannot be empty."
            return false
        }
        
        guard let amount = Decimal(string: targetAmount), amount > 0 else {
            errorMessage = "Please enter a valid target amount greater than 0."
            return false
        }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            // Fetch real creator UUID from the users table based on the logged-in session
            let sessionUser = try await SupabaseManager.shared.client.auth.session.user
            
            struct UserRecord: Decodable {
                let id: UUID
            }
            
            let userRecord: UserRecord = try await SupabaseManager.shared.client
                .from("users")
                .select("id")
                .eq("supabase_auth_id", value: sessionUser.id)
                .single()
                .execute()
                .value
                
            _ = try await createCampaignAction(userRecord.id, title, description, category, amount, nil)
            isSubmitting = false
            return true
        } catch {
            isSubmitting = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
