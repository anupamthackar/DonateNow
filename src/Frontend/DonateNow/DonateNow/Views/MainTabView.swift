import SwiftUI

struct MainTabView: View {
    @StateObject private var authService = AuthService.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 0: Explore (Marketplace)
            NavigationStack {
                MarketplaceView()
            }
            .tag(0)
            .tabItem {
                Label("Explore", systemImage: selectedTab == 0 ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
            }
            
            // Tab 1: Creator
            NavigationStack {
                MyCampaignsView()
            }
            .tag(1)
            .tabItem {
                Label("Creator", systemImage: selectedTab == 1 ? "plus.rectangle.on.rectangle.fill" : "plus.rectangle.on.rectangle")
            }
            
            // Tab 2: Profile
            NavigationStack {
                UserProfileView()
            }
            .tag(2)
            .tabItem {
                Label("Profile", systemImage: selectedTab == 2 ? "person.crop.circle.fill" : "person.crop.circle")
            }
            
            // Tab 3: Admin (Conditional based on features/role)
            if authService.isAdmin {
                NavigationStack {
                    AdminDashboardView()
                }
                .tag(3)
                .tabItem {
                    Label("Admin", systemImage: selectedTab == 3 ? "person.badge.key.fill" : "person.badge.key")
                }
            }
        }
        .tint(Color.theme.primary)
    }
}

#Preview {
    MainTabView()
}
