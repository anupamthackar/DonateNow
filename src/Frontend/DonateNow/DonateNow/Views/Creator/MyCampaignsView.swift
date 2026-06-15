import SwiftUI

struct MyCampaignsView: View {
    @State private var campaigns: [DonationProfile] = []
    @State private var isLoading: Bool = true
    @State private var showingCreateCampaign: Bool = false
    @StateObject private var authService = AuthService.shared
    
    private let repository = CampaignRepository()
    
    var body: some View {
        Group {
                if isLoading {
                    ProgressView("Loading campaigns...")
                } else if campaigns.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "megaphone")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("You haven't created any campaigns yet.")
                            .foregroundColor(.secondary)
                        Button("Create Campaign") {
                            showingCreateCampaign = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(campaigns) { campaign in
                            NavigationLink(destination: CampaignManagementDetailView(campaign: campaign)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(campaign.title)
                                        .font(.headline)
                                    
                                    HStack {
                                        StatusBadge(status: campaign.verificationStatus.rawValue)
                                        Spacer()
                                        Text("₹\(campaign.raisedAmount.description) raised")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        .navigationTitle("My Campaigns")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreateCampaign = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateCampaign, onDismiss: {
            loadCampaigns()
        }) {
            CreateCampaignView()
        }
        .onAppear {
            loadCampaigns()
        }
    }
    
    private func loadCampaigns() {
        isLoading = true
        Task {
            do {
                guard let userId = authService.currentUser?.id else {
                    await MainActor.run { self.isLoading = false }
                    return
                }
                let fetchedCampaigns = try await repository.getCampaignsForCreator(creatorId: userId)
                await MainActor.run {
                    self.campaigns = fetchedCampaigns
                    self.isLoading = false
                }
            } catch {
                print("Failed to fetch campaigns: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

struct CampaignManagementDetailView: View {
    let campaign: DonationProfile
    
    var body: some View {
        VStack(spacing: 20) {
            Text(campaign.title)
                .font(.title)
                .bold()
            
            Text(campaign.description)
                .foregroundColor(.secondary)
            
            if campaign.verificationStatus == .draft {
                NavigationLink(destination: DocumentUploadView(campaignId: campaign.id)) {
                    Text("Verify Campaign")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else if campaign.verificationStatus == .pending {
                Text("Verification Pending. Please wait for admin approval.")
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
            } else if campaign.verificationStatus == .verified {
                Text("Campaign is Active and Verified!")
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Manage")
    }
}

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(colorForStatus(status).opacity(0.2))
            .foregroundColor(colorForStatus(status))
            .cornerRadius(8)
    }
    
    private func colorForStatus(_ status: String) -> Color {
        switch status.lowercased() {
        case "draft": return .gray
        case "pending": return .orange
        case "verified": return .green
        case "rejected": return .red
        default: return .gray
        }
    }
}

#Preview {
    MyCampaignsView()
}
