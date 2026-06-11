import Foundation
import Combine
import Supabase

@MainActor
class DonorLogViewModel: ObservableObject {
    private let client = SupabaseManager.shared.client
    
    @Published var donations: [Donation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Filters & Search
    @Published var searchText = ""
    @Published var startDate = Date().addingTimeInterval(-30 * 24 * 60 * 60) // Last 30 days
    @Published var endDate = Date()
    @Published var isFilterActive = false
    
    func fetchDonations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("DEBUG - fetchDonations: calling RPC get_all_donations")
            let fetched: [Donation] = try await client
                .rpc("get_all_donations")
                .execute()
                .value
            print("DEBUG - fetchDonations: successfully fetched \(fetched.count) donations: \(fetched)")
            
            var filtered = fetched
            if isFilterActive {
                filtered = filtered.filter { donation in
                    donation.createdAt >= startDate && donation.createdAt <= endDate
                }
            }
            
            if searchText.isEmpty {
                self.donations = filtered
            } else {
                let lowerSearch = searchText.lowercased()
                self.donations = filtered.filter { donation in
                    donation.donorName.lowercased().contains(lowerSearch) ||
                    donation.donorEmail.lowercased().contains(lowerSearch)
                }
            }
        } catch {
            print("DEBUG - fetchDonations: failed with error: \(error)")
            if Task.isCancelled { return }
            self.errorMessage = "Failed to load donations: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
