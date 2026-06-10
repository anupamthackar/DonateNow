import Foundation
import Supabase

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let client = SupabaseManager.shared.client
    
    @Published var session: Session?
    
    var isAuthenticated: Bool {
        session != nil
    }
    
    private init() {
        Task {
            for await event in client.auth.authStateChanges {
                self.session = event.session
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signInWithPassword(email: email, password: password)
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
}
