import SwiftUI
import Supabase

struct AdminDashboardView: View {
    @State private var selectedSection = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Section Picker
            Picker("Dashboard Section", selection: $selectedSection) {
                Text("Overview").tag(0)
                Text("Campaigns").tag(1)
                Text("Payments").tag(2)
                Text("Verify").tag(3)
            }
            .pickerStyle(.segmented)
            .padding()
            
            switch selectedSection {
            case 0:
                AdminOverviewSection()
            case 1:
                AdminCampaignsSection()
            case 2:
                AdminPaymentLogsSection()
            case 3:
                AdminVerificationQueueSection()
            default:
                EmptyView()
            }
            Spacer()
        }
        .navigationTitle("Admin Dashboard")
    }
}

// MARK: - Overview Section

struct AdminOverviewSection: View {
    @State private var totalCampaigns: Int = 0
    @State private var totalDonations: Int = 0
    @State private var totalRaised: Decimal = 0
    @State private var isLoading = true
    
    private let client = SupabaseManager.shared.client
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Loading stats...")
                    .padding(.top, 40)
            } else {
                VStack(spacing: 16) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "Campaigns", value: "\(totalCampaigns)", icon: "megaphone.fill", color: .blue)
                        StatCard(title: "Donations", value: "\(totalDonations)", icon: "heart.fill", color: .pink)
                    }
                    
                    StatCard(
                        title: "Total Raised",
                        value: Formatters.formatCurrency(amount: totalRaised),
                        icon: "indianrupeesign.circle.fill",
                        color: .green
                    )
                }
                .padding()
            }
        }
        .task { await loadStats() }
    }
    
    private func loadStats() async {
        do {
            let campaigns: [DonationProfile] = try await client
                .from("donation_profiles").select().execute().value
            totalCampaigns = campaigns.count
            totalRaised = campaigns.reduce(Decimal(0)) { $0 + $1.raisedAmount }
            
            struct DonationCount: Codable { let id: UUID }
            let donations: [DonationCount] = try await client
                .from("donations").select("id").eq("status", value: "completed").execute().value
            totalDonations = donations.count
        } catch {
            print("Admin stats error: \(error)")
        }
        isLoading = false
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            Text(value)
                .font(.title2).bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - All Campaigns Section

struct AdminCampaignsSection: View {
    @State private var campaigns: [DonationProfile] = []
    @State private var isLoading = true
    private let client = SupabaseManager.shared.client
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading campaigns...")
            } else if campaigns.isEmpty {
                Text("No campaigns found.").foregroundColor(.secondary).padding()
            } else {
                List(campaigns) { campaign in
                    NavigationLink(destination: CampaignDetailView(campaign: campaign)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(campaign.title).font(.headline)
                                Spacer()
                                StatusBadge(status: campaign.verificationStatus.rawValue)
                            }
                            HStack {
                                if let cat = campaign.category {
                                    Text(cat).font(.caption).foregroundColor(Color.theme.primary)
                                }
                                Spacer()
                                Text(Formatters.formatCurrency(amount: campaign.raisedAmount))
                                    .font(.caption).bold().foregroundColor(.green)
                                Text("/ \(Formatters.formatCurrency(amount: campaign.targetAmount))")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .task { await loadCampaigns() }
    }
    
    private func loadCampaigns() async {
        do {
            campaigns = try await client
                .from("donation_profiles")
                .select("*, users(name)")
                .order("created_at", ascending: false)
                .execute().value
        } catch {
            print("Admin campaigns error: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Payment Logs Section

struct AdminPaymentLogsSection: View {
    @State private var logs: [AdminPaymentLogEntry] = []
    @State private var isLoading = true
    private let client = SupabaseManager.shared.client
    
    struct AdminPaymentLogEntry: Codable, Identifiable {
        let id: UUID
        let donationId: UUID
        let eventType: String
        let amount: Decimal
        let status: String
        let razorpayEventId: String?
        let createdAt: Date
        
        enum CodingKeys: String, CodingKey {
            case id
            case donationId = "donation_id"
            case eventType = "event_type"
            case amount, status
            case razorpayEventId = "razorpay_event_id"
            case createdAt = "created_at"
        }
    }
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading payment logs...")
            } else if logs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40)).foregroundColor(.secondary)
                    Text("No payment logs found.").foregroundColor(.secondary)
                }.padding(.top, 40)
            } else {
                List(logs) { log in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "creditcard.fill").foregroundColor(.green)
                            Text(Formatters.formatCurrency(amount: log.amount)).font(.headline)
                            Spacer()
                            Text(log.status.uppercased())
                                .font(.caption2).bold()
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(log.status == "completed" ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                                .foregroundColor(log.status == "completed" ? .green : .orange)
                                .cornerRadius(6)
                        }
                        Text(log.eventType).font(.caption).foregroundColor(.secondary)
                        if let rpId = log.razorpayEventId {
                            Text("Payment: \(rpId)").font(.caption2).foregroundColor(.secondary).lineLimit(1)
                        }
                        Text(Formatters.formatDate(log.createdAt)).font(.caption2).foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.insetGrouped)
            }
        }
        .task { await loadLogs() }
    }
    
    private func loadLogs() async {
        do {
            logs = try await client
                .from("payment_logs").select()
                .order("created_at", ascending: false).limit(100)
                .execute().value
        } catch {
            print("Admin payment logs error: \(error)")
        }
        isLoading = false
    }
}

// MARK: - Verification Queue (Embedded)

struct AdminVerificationQueueSection: View {
    @State private var requests: [VerificationRequest] = []
    @State private var isLoading: Bool = true
    private let verificationRepo = VerificationRepository()
    
    var body: some View {
        Spacer()
        Group {
            if isLoading {
                ProgressView("Loading queue...")
            } else if requests.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60)).foregroundColor(.green)
                    Text("Queue is empty. All caught up!").foregroundColor(.secondary)
                }.padding(.top, 40)
            } else {
                List {
                    ForEach(requests) { request in
                        NavigationLink(destination: CampaignReviewView(request: request, onReviewComplete: loadQueue)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Campaign ID: \(request.campaignId.uuidString.prefix(8))").font(.headline)
                                HStack {
                                    Text("Submitted: \(request.submittedAt.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption).foregroundColor(.secondary)
                                    Spacer()
                                    Text(request.status.rawValue.uppercased())
                                        .font(.caption2).bold()
                                        .padding(.horizontal, 6).padding(.vertical, 2)
                                        .background(Color.orange.opacity(0.2)).foregroundColor(.orange).cornerRadius(4)
                                }
                            }.padding(.vertical, 4)
                        }
                    }
                }.listStyle(.insetGrouped)
            }
        }
        Spacer()
        .task { loadQueue() }
    }
    
    private func loadQueue() {
        isLoading = true
        Task {
            do {
                let fetched = try await verificationRepo.getVerificationQueue()
                await MainActor.run { self.requests = fetched; self.isLoading = false }
            } catch {
                print("Failed to fetch queue: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

#Preview {
    NavigationStack { AdminDashboardView() }
}
