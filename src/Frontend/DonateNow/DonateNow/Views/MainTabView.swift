import SwiftUI

struct MainTabView: View {
    @StateObject private var authService = AuthService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DonationView()
            }
            .tag(0)
            .tabItem {
                Label("Donate", systemImage: selectedTab == 0 ? "heart.fill" : "heart")
            }
            
            NavigationStack {
                if authService.isAuthenticated {
                    AdminDashboardView()
                } else {
                    AdminLoginView()
                }
            }
            .tag(1)
            .tabItem {
                Label("Admin", systemImage: selectedTab == 1 ? "person.badge.key.fill" : "person.badge.key")
            }
        }
        .tint(Color.theme.primary)
    }
}

#Preview {
    MainTabView()
}
