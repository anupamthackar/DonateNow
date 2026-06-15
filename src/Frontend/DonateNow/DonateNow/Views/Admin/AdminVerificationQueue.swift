import SwiftUI

struct AdminVerificationQueue: View {
    @State private var requests: [VerificationRequest] = []
    @State private var isLoading: Bool = true
    
    private let verificationRepo = VerificationRepository()
    
    var body: some View {
        Group {
                if isLoading {
                    ProgressView("Loading queue...")
                } else if requests.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("Queue is empty. All caught up!")
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(requests) { request in
                            NavigationLink(destination: CampaignReviewView(request: request, onReviewComplete: loadQueue)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Campaign ID: \(request.campaignId.uuidString.prefix(8))")
                                        .font(.headline)
                                    
                                    HStack {
                                        Text("Submitted: \(request.submittedAt.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text(request.status.rawValue.uppercased())
                                            .font(.caption2)
                                            .bold()
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.orange.opacity(0.2))
                                            .foregroundColor(.orange)
                                            .cornerRadius(4)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        .navigationTitle("Verification Queue")
        .onAppear {
            loadQueue()
        }
    }
    
    private func loadQueue() {
        isLoading = true
        Task {
            do {
                let fetched = try await verificationRepo.getVerificationQueue()
                await MainActor.run {
                    self.requests = fetched
                    self.isLoading = false
                }
            } catch {
                print("Failed to fetch queue: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

#Preview {
    AdminVerificationQueue()
}
