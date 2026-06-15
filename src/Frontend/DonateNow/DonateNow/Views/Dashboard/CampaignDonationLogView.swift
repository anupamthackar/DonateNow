import SwiftUI

struct CampaignDonationLogView: View {
    let campaignId: UUID
    @State private var logs: [PaymentLog] = []
    @State private var isLoading: Bool = true
    
    private let supabase = SupabaseManager.shared.client
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading logs...")
            } else if logs.isEmpty {
                VStack {
                    Image(systemName: "tray")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No donations yet.")
                        .foregroundColor(.secondary)
                }
            } else {
                List(logs) { log in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(log.eventType == "subscription.charged" ? "Subscription" : "One-Time")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                            
                            Spacer()
                            
                            Text("₹\(log.amount.description)")
                                .bold()
                        }
                        
                        HStack {
                            Text(log.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(log.status.uppercased())
                                .font(.caption2)
                                .bold()
                                .foregroundColor(log.status == "completed" ? .green : .red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Donation Log")
        .onAppear(perform: loadLogs)
    }
    
    private func loadLogs() {
        isLoading = true
        Task {
            // Mocking the logs for prototype
            try await Task.sleep(nanoseconds: 1_000_000_000)
            await MainActor.run {
                self.logs = [
                    PaymentLog(id: UUID(), donationId: UUID(), eventType: "payment.captured", amount: 5000, status: "completed", razorpayEventId: "pay_123", metadataJson: nil, createdAt: Date()),
                    PaymentLog(id: UUID(), donationId: UUID(), eventType: "subscription.charged", amount: 1000, status: "completed", razorpayEventId: "pay_124", metadataJson: nil, createdAt: Date().addingTimeInterval(-86400)),
                    PaymentLog(id: UUID(), donationId: UUID(), eventType: "payment.failed", amount: 2000, status: "failed", razorpayEventId: "pay_125", metadataJson: nil, createdAt: Date().addingTimeInterval(-86400 * 2))
                ]
                self.isLoading = false
            }
        }
    }
}
