import SwiftUI

struct MarketplaceView: View {
    @State private var campaigns: [DonationProfile] = []
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"
    @State private var isLoading: Bool = true
    
    let categories = ["All", "Education", "Medical", "Environment", "Community", "Disaster Relief"]
    private let searchService = CampaignSearchService()
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            SearchBar(text: $searchText, onSearch: performSearch)
                .padding()
            
            // Categories ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        CategoryPill(title: category, isSelected: selectedCategory == category) {
                            selectedCategory = category
                            performCategoryFilter()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            
            if isLoading {
                Spacer()
                ProgressView("Discovering causes...")
                Spacer()
            } else if campaigns.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No campaigns found.")
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(campaigns) { campaign in
                            NavigationLink(destination: CampaignDetailView(campaign: campaign)) {
                                CampaignCardView(campaign: campaign)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Discover Causes")
        .onAppear {
            if campaigns.isEmpty {
                loadAllCampaigns()
            }
        }
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty {
                selectedCategory = "All"
                loadAllCampaigns()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .donationCompleted)) { _ in
            loadAllCampaigns()
        }
    }
    
    private func loadAllCampaigns() {
        isLoading = true
        Task {
            do {
                let fetched = try await searchService.fetchDiscoverableCampaigns()
                await MainActor.run {
                    self.campaigns = fetched
                    self.isLoading = false
                }
            } catch {
                print("DEBUG - fetchDiscoverableCampaigns Error: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        selectedCategory = "All" // Reset category when searching text
        isLoading = true
        Task {
            do {
                let fetched = try await searchService.searchCampaigns(query: searchText)
                await MainActor.run {
                    self.campaigns = fetched
                    self.isLoading = false
                }
            } catch {
                print("DEBUG - searchCampaigns Error: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func performCategoryFilter() {
        searchText = "" // Reset search text when using categories
        isLoading = true
        Task {
            do {
                let fetched: [DonationProfile]
                if selectedCategory == "All" {
                    fetched = try await searchService.fetchDiscoverableCampaigns()
                } else {
                    fetched = try await searchService.filterByCategory(category: selectedCategory)
                }
                await MainActor.run {
                    self.campaigns = fetched
                    self.isLoading = false
                }
            } catch {
                print("DEBUG - filterByCategory Error: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

// MARK: - Subcomponents

struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search campaigns...", text: $text, onCommit: onSearch)
                .submitLabel(.search)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.theme.primary : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    MarketplaceView()
}
