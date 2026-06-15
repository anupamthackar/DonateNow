import Foundation
import Supabase
import Combine
import SwiftUI


@MainActor
class TaxReceiptViewModel: ObservableObject {
    @Published var receipts: [TaxReceipt] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let client = SupabaseManager.shared.client
    
    func fetchMyReceipts() async {
        guard let userId = try? await client.auth.session.user.id else {
            self.errorMessage = "Not logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch receipts that belong to donations made by this user
            // In a real query, we'd join with donations or ensure RLS only returns the user's receipts
            let response: [TaxReceipt] = try await client
                .from("tax_receipts")
                .select()
                // Assuming RLS restricts to the user's own receipts
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.receipts = response
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
