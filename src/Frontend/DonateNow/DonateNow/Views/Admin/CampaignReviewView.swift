import SwiftUI

struct CampaignReviewView: View {
    let request: VerificationRequest
    var onReviewComplete: () -> Void
    
    @State private var rejectionReason: String = ""
    @State private var isProcessing: Bool = false
    @State private var showingRejectAlert: Bool = false
    
    private let verificationRepo = VerificationRepository()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Campaign Details")) {
                LabeledContent("Campaign ID", value: String(request.campaignId.uuidString.prefix(8)))
                LabeledContent("Status", value: request.status.rawValue.capitalized)
                LabeledContent("Submitted", value: request.submittedAt.formatted())
            }
            
            Section(header: Text("Documents (\(request.documentsUrl.count))")) {
                ForEach(request.documentsUrl, id: \.self) { url in
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.blue)
                        Text(url.components(separatedBy: "/").last ?? "Document")
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button("View") {
                            // In a real app, open the PDF or image URL
                        }
                    }
                }
            }
            
            Section {
                Button(action: approveCampaign) {
                    HStack {
                        Spacer()
                        if isProcessing {
                            ProgressView()
                        } else {
                            Text("Approve Campaign")
                                .bold()
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.green)
                .disabled(isProcessing)
                
                Button(action: { showingRejectAlert = true }) {
                    HStack {
                        Spacer()
                        Text("Reject")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                .disabled(isProcessing)
            }
        }
        .navigationTitle("Review Campaign")
        .alert("Reject Campaign", isPresented: $showingRejectAlert) {
            TextField("Reason for rejection", text: $rejectionReason)
            Button("Cancel", role: .cancel) { }
            Button("Reject", role: .destructive, action: rejectCampaign)
        } message: {
            Text("Please provide a reason for rejecting these verification documents.")
        }
    }
    
    private func approveCampaign() {
        isProcessing = true
        Task {
            do {
                // Simulated admin ID
                let adminId = UUID() 
                try await verificationRepo.approveCampaign(
                    requestId: request.id,
                    campaignId: request.campaignId,
                    adminId: adminId
                )
                
                await MainActor.run {
                    isProcessing = false
                    onReviewComplete()
                    dismiss()
                }
            } catch {
                print("Approve failed: \(error)")
                await MainActor.run { isProcessing = false }
            }
        }
    }
    
    private func rejectCampaign() {
        guard !rejectionReason.isEmpty else { return }
        
        isProcessing = true
        Task {
            do {
                let adminId = UUID()
                try await verificationRepo.rejectCampaign(
                    requestId: request.id,
                    campaignId: request.campaignId,
                    adminId: adminId,
                    reason: rejectionReason
                )
                
                await MainActor.run {
                    isProcessing = false
                    onReviewComplete()
                    dismiss()
                }
            } catch {
                print("Reject failed: \(error)")
                await MainActor.run { isProcessing = false }
            }
        }
    }
}
