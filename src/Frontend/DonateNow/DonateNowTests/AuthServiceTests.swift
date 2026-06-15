import Testing
import Foundation
@testable import DonateNow

@MainActor
struct AuthServiceTests {
    
    @Test("TC-Auth: User is Admin")
    func testIsAdminRole() async throws {
        let authService = AuthService.shared
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for auth observer to initialize
        
        let adminUser = AppUser(id: UUID(), email: "admin@donatenow.com", name: "Admin User", role: "admin", supabase_auth_id: UUID(), features: nil)
        authService.currentUser = adminUser
        
        #expect(authService.isAdmin == true)
        #expect(authService.isAuthenticated == false) // Because session is nil
    }
    
    @Test("TC-Auth: User is Donor")
    func testIsDonorRole() async throws {
        let authService = AuthService.shared
        
        let donorUser = AppUser(id: UUID(), email: "donor@gmail.com", name: "Donor User", role: "donor", supabase_auth_id: UUID(), features: nil)
        authService.currentUser = donorUser
        
        #expect(authService.isAdmin == false)
    }
    
    @Test("TC-Auth: User is Creator")
    func testIsCreatorRole() async throws {
        let authService = AuthService.shared
        
        let creatorUser = AppUser(id: UUID(), email: "ngo@gmail.com", name: "NGO", role: "creator", supabase_auth_id: UUID(), features: nil)
        authService.currentUser = creatorUser
        
        #expect(authService.isAdmin == false)
    }
}
