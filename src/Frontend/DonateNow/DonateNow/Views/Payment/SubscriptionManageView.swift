import SwiftUI

struct SubscriptionManageView: View {
    @State private var subscriptions: [Subscription] = []
    @State private var isLoading: Bool = true
    
    // In real app, we would have a SubscriptionService
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading subscriptions...")
                } else if subscriptions.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.minus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No active subscriptions.")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(subscriptions) { sub in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(sub.campaignTitle ?? "Campaign")
                                    .font(.headline)
                                
                                HStack {
                                    Text("₹\(sub.amount.description) / \(sub.frequency)")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(sub.status.rawValue.uppercased())
                                        .font(.caption)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(sub.status == .active ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                                        .foregroundColor(sub.status == .active ? .green : .red)
                                        .cornerRadius(4)
                                }
                                
                                if sub.status == .active, let nextDate = sub.nextChargeDate {
                                    Text("Next charge: \(nextDate.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                if sub.status == .active {
                                    Button(role: .destructive, action: { cancelSubscription(sub) }) {
                                        Text("Cancel Subscription")
                                            .font(.caption)
                                            .bold()
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("My Subscriptions")
            .onAppear(perform: loadSubscriptions)
        }
    }
    
    private func loadSubscriptions() {
        isLoading = true
        Task {
            do {
                // Mocking fetch
                // let fetched = try await supabase.from("subscriptions").select().eq("user_id", auth.uid).execute().value
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                await MainActor.run {
                    self.subscriptions = [
                        Subscription(id: UUID(), userId: UUID(), campaignId: UUID(), razorpaySubId: "sub_123", amount: 1000, currency: "INR", frequency: "monthly", status: .active, nextChargeDate: Date().addingTimeInterval(86400 * 15), retryCount: 0, createdAt: Date(), updatedAt: Date(), cancelledAt: nil, campaignTitle: "Save the Forests", campaignImageUrl: nil)
                    ]
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func cancelSubscription(_ sub: Subscription) {
        // Call cancel-subscription edge function
        print("Cancelling \(sub.razorpaySubId)")
    }
}

#Preview {
    SubscriptionManageView()
}
