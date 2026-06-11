import Foundation
import Combine
import Supabase

@MainActor
class DashboardViewModel: ObservableObject {
    private let client = SupabaseManager.shared.client
    
    @Published var totalCount: Int = 0
    @Published var totalAmount: Double = 0.0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    struct DonationStats: Codable {
        let total_count: Int
        let total_amount: Double
    }
    
    func fetchStats() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let stats: DonationStats = try await client
                .rpc("get_donation_stats")
                .execute()
                .value
            
            self.totalCount = stats.total_count
            self.totalAmount = stats.total_amount
        } catch {
            if Task.isCancelled { return }
            self.errorMessage = "Failed to load stats: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
