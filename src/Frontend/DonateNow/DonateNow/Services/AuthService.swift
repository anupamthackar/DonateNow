import Foundation
import Combine
import Supabase

struct AppUser: Codable {
    let id: UUID
    let email: String
    let name: String
    let role: String
    let supabase_auth_id: UUID
    let features: [String]?
}

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()
    
    private let client = SupabaseManager.shared.client
    
    @Published var session: Session?
    @Published var currentUser: AppUser?
    
    var isAuthenticated: Bool {
        session != nil
    }
    
    var isAdmin: Bool {
        currentUser?.role == "admin" || (currentUser?.features?.contains("admin_dashboard") == true)
    }
    
    private init() {
        Task {
            for await event in client.auth.authStateChanges {
                self.session = event.session
                if event.session != nil {
                    await fetchUserProfile()
                } else {
                    self.currentUser = nil
                }
            }
        }
    }
    
    func fetchUserProfile() async {
        guard let userId = session?.user.id else { return }
        do {
            let user: AppUser = try await client
                .from("users")
                .select()
                .eq("supabase_auth_id", value: userId.uuidString)
                .single()
                .execute()
                .value
            self.currentUser = user
        } catch {
            print("Error fetching user profile: \(error)")
        }
    }
    
    func signUp(email: String, password: String, name: String) async throws {
        let authResponse = try await client.auth.signUp(email: email, password: password)
        let userId = authResponse.user.id
        
        struct CreateUserReq: Encodable {
            let email: String
            let name: String
            let supabase_auth_id: String
            let role: String
            let features: [String]
        }
        
        let req = CreateUserReq(email: email, name: name, supabase_auth_id: userId.uuidString, role: "donor", features: ["donate", "create_campaign", "view_profile"])
        
        try await client
            .from("users")
            .insert(req)
            .execute()
            
        await fetchUserProfile()
    }
    
    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
        await fetchUserProfile()
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        self.currentUser = nil
    }
}
