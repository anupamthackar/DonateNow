import SwiftUI

struct CreatorDashboardView: View {
    let campaign: DonationProfile
    @State private var stats: CampaignStats?
    @State private var isLoading: Bool = true
    
    private let analyticsService = AnalyticsService()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text(campaign.title)
                        .font(.title2)
                        .bold()
                    Text("Creator Dashboard")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                if isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if let stats = stats {
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        DashboardStatsCard(
                            title: "Total Raised",
                            value: "₹\(stats.totalRaised.description)",
                            icon: "indianrupesign.circle.fill",
                            color: .green
                        )
                        DashboardStatsCard(
                            title: "Total Donors",
                            value: "\(stats.totalDonors)",
                            icon: "person.2.fill",
                            color: .blue
                        )
                        DashboardStatsCard(
                            title: "Donations",
                            value: "\(stats.totalDonations)",
                            icon: "gift.fill",
                            color: .orange
                        )
                        DashboardStatsCard(
                            title: "Avg Donation",
                            value: "₹\(stats.avgDonation.description)",
                            icon: "chart.bar.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Quick Actions / Links
                    VStack(spacing: 1) {
                        NavigationLink(destination: CampaignDonationLogView(campaignId: campaign.id)) {
                            DashboardRow(title: "View Donation Log", icon: "list.bullet.rectangle")
                        }
                        NavigationLink(destination: ImpactReportView(campaignId: campaign.id)) {
                            DashboardRow(title: "AI Impact Reports", icon: "sparkles.rectangle.stack")
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadStats)
    }
    
    private func loadStats() {
        isLoading = true
        Task {
            do {
                let fetchedStats = try await analyticsService.getCampaignStats(campaignId: campaign.id)
                await MainActor.run {
                    self.stats = fetchedStats
                    self.isLoading = false
                }
            } catch {
                // For prototype, mock data if real backend fails
                await MainActor.run {
                    self.stats = CampaignStats(totalRaised: 150000, totalDonors: 120, totalDonations: 150, avgDonation: 1000, latestDonation: Date())
                    self.isLoading = false
                }
            }
        }
    }
}

struct DashboardRow: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(title)
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
