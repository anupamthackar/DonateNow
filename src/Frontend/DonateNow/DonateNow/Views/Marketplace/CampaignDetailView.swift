import SwiftUI

struct CampaignDetailView: View {
    let campaign: DonationProfile
    @State private var showingDonationSheet = false
    @State private var liveCampaign: DonationProfile?
    
    private let searchService = CampaignSearchService()
    
    private var displayCampaign: DonationProfile {
        liveCampaign ?? campaign
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Image with proper loading states
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 250)
                    
                    if let urlString = displayCampaign.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 250)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 250)
                                    .clipped()
                                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
                            case .failure:
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.5))
                                    .frame(height: 250)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No image available")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 250)
                    }
                }
                .clipped()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title and Category
                    VStack(alignment: .leading, spacing: 8) {
                        if let category = displayCampaign.category {
                            Text(category.uppercased())
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(Color.theme.primary)
                        }
                        
                        Text(displayCampaign.title)
                            .font(.title)
                            .bold()
                        
                        if let creatorName = displayCampaign.creatorName {
                            Text("By \(creatorName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Progress Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(Formatters.formatCurrency(amount: displayCampaign.raisedAmount)) collected from \(Formatters.formatCurrency(amount: displayCampaign.targetAmount)) goal")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        CampaignProgressBar(raised: displayCampaign.raisedAmount, target: displayCampaign.targetAmount)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Button(action: { showingDonationSheet = true }) {
                            Text("Donate Now")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.theme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        ShareLink(
                            item: "Support \"\(displayCampaign.title)\" on DonateNow! Help raise \(Formatters.formatCurrency(amount: displayCampaign.targetAmount)) for this cause.",
                            subject: Text(displayCampaign.title),
                            message: Text(displayCampaign.description)
                        ) {
                            Image(systemName: "square.and.arrow.up")
                                .padding()
                                .background(Color(.systemGray6))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                    }
                    
                    Divider()
                    
                    // Story
                    VStack(alignment: .leading, spacing: 12) {
                        Text("The Story")
                            .font(.title3)
                            .bold()
                        
                        Text(displayCampaign.description)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    
                    Divider()
                    
                    // Donor Wall
                    NavigationLink(destination: DonorWallView(campaignId: displayCampaign.id)) {
                        HStack {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(Color.theme.primary)
                            Text("Donor Wall")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Divider()
                    
                    // AI Impact Reports
                    NavigationLink(destination: ImpactReportView(campaignId: displayCampaign.id)) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                            Text("AI Impact Reports")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDonationSheet, onDismiss: {
            // Refresh campaign data after donation sheet is dismissed
            refreshCampaign()
        }) {
            NavigationStack {
                DonationView(causeId: displayCampaign.id)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showingDonationSheet = false }
                        }
                    }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .donationCompleted)) { notification in
            if let amount = notification.userInfo?["amount"] as? Double,
               let causeId = notification.userInfo?["causeId"] as? UUID,
               causeId == campaign.id {
                let decimalAmount = Decimal(amount)
                if var currentCampaign = liveCampaign {
                    currentCampaign.raisedAmount += decimalAmount
                    liveCampaign = currentCampaign
                } else {
                    var newCampaign = campaign
                    newCampaign.raisedAmount += decimalAmount
                    liveCampaign = newCampaign
                }
            } else {
                refreshCampaign()
            }
        }
    }
    
    private func refreshCampaign() {
        Task {
            do {
                let campaigns = try await searchService.fetchDiscoverableCampaigns()
                if let updated = campaigns.first(where: { $0.id == campaign.id }) {
                    await MainActor.run {
                        self.liveCampaign = updated
                    }
                }
            } catch {
                print("DEBUG - Campaign refresh error: \(error)")
            }
        }
    }
}
