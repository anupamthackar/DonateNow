import SwiftUI
import Supabase
import Combine



@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let client = SupabaseManager.shared.client
    
    func fetchSubscriptions() async {
        guard let _ = try? await client.auth.session.user.id else {
            self.errorMessage = "Not logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Fetch subscriptions joined with cause details
            // This assumes a foreign key from subscriptions to donation_profiles exists
            let response: [Subscription] = try await client
                .from("subscriptions")
                .select("*, donation_profiles!inner(title)")
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.subscriptions = response
        } catch {
            // Fallback for mocked UI if table join fails or schema is incomplete
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func cancelSubscription(_ id: UUID) async {
        // Here we would call an edge function to cancel via Razorpay API
        // For now, we simulate success
        if let index = subscriptions.firstIndex(where: { $0.id == id }) {
            // Optimistic update
            var sub = subscriptions[index]
            // We can't mutate struct directly if let, so we'd need a mutable model
            // For prototype:
            await fetchSubscriptions()
        }
    }
}

struct SubscriptionManagementView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var showingCancelAlert = false
    @State private var subscriptionToCancel: UUID?
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading subscriptions...")
            } else if let error = viewModel.errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text("Could not load subscriptions.\n\(error)")
                        .multilineTextAlignment(.center)
                        .padding()
                }
            } else if viewModel.subscriptions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No active subscriptions.")
                        .font(.headline)
                    Text("When you choose to donate monthly, your recurring donations will appear here.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            } else {
                List {
                    ForEach(viewModel.subscriptions) { subscription in
                        SubscriptionRowView(
                            subscription: subscription,
                            onCancel: {
                                subscriptionToCancel = subscription.id
                                showingCancelAlert = true
                            }
                        )
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("Monthly Donations")
        .task {
            await viewModel.fetchSubscriptions()
        }
        .alert("Cancel Monthly Donation?", isPresented: $showingCancelAlert) {
            Button("Keep Donating", role: .cancel) {}
            Button("Cancel Subscription", role: .destructive) {
                if let id = subscriptionToCancel {
                    Task {
                        await viewModel.cancelSubscription(id)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to stop this monthly donation? The cause relies on your continued support.")
        }
    }
}

struct SubscriptionRowView: View {
    let subscription: Subscription
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(subscription.campaignTitle ?? "Campaign Donation")
                    .font(.headline)
                Spacer()
                Text(subscription.status.rawValue.uppercased())
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Formatters.formatCurrency(amount: subscription.amount)) / month")
                        .bold()
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Next Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(nextDateString)
                        .bold()
                }
            }
            
            if subscription.status == .active {
                Divider()
                Button(action: onCancel) {
                    Text("Cancel Subscription")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var statusColor: Color {
        switch subscription.status {
        case .active: return .green
        case .cancelled: return .gray
        case .expired: return .orange
        case .paused: return .blue
        }
    }
    
    private var nextDateString: String {
        guard let date = subscription.nextChargeDate else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
