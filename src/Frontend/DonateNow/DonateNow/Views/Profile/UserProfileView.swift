import SwiftUI

struct UserProfileView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        List {
            Section("Account Details") {
                if let user = authService.currentUser {
                    Text("Name: \(user.name)")
                    Text("Email: \(user.email)")
                    Text("Role: \(user.role.capitalized)")
                } else {
                    Text("Loading profile...")
                }
            }
            
            Section("Donations & Subscriptions") {
                NavigationLink("My Subscriptions") {
                    SubscriptionManagementView()
                }
                
                NavigationLink("My Tax Receipts (80G)") {
                    TaxReceiptListView()
                }
            }
            
            Section {
                Button(role: .destructive) {
                    Task {
                        try? await authService.signOut()
                    }
                } label: {
                    Text("Log Out")
                }
            }
        }
        .navigationTitle("Profile")
    }
}
