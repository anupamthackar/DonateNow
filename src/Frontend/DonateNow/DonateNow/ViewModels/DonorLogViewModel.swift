import Foundation
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
            var query = client
                .from("donations")
                .select()
                .eq("status", "completed") // only view completed donations in admin log
                .order("created_at", ascending: false)
            
            if isFilterActive {
                let startISO = ISO8601DateFormatter().string(from: startDate)
                let endISO = ISO8601DateFormatter().string(from: endDate)
                
                query = query
                    .gte("created_at", value: startISO)
                    .lte("created_at", value: endISO)
            }
            
            let fetched: [Donation] = try await query.execute().value
            
            // Search client side or add complex SQL. Client side is fine for list size
            if searchText.isEmpty {
                self.donations = fetched
            } else {
                let lowerSearch = searchText.lowercased()
                self.donations = fetched.filter { donation in
                    donation.donorName.lowercased().contains(lowerSearch) ||
                    donation.donorEmail.lowercased().contains(lowerSearch)
                }
            }
        } catch {
            self.errorMessage = "Failed to load donations: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
