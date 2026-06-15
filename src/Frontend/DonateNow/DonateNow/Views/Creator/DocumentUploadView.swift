import SwiftUI

struct DocumentUploadView: View {
    let campaignId: UUID
    @State private var isUploading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    
    // In production, this would use a real document picker (UIDocumentPickerViewController)
    // For this prototype, we simulate a file selection.
    @State private var selectedFileName: String? = nil
    
    private let verificationRepo = VerificationRepository()
    private let fileUploadService = FileUploadService()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Verify Your Campaign")
                .font(.title2)
                .bold()
            
            Text("Please upload official NGO registration certificates or identity documents to verify your campaign.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            if let selectedFileName = selectedFileName {
                HStack {
                    Image(systemName: "doc.fill")
                        .foregroundColor(.blue)
                    Text(selectedFileName)
                    Spacer()
                    Button(action: { self.selectedFileName = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            } else {
                Button(action: {
                    // Simulate file selection
                    selectedFileName = "80G_Certificate.pdf"
                }) {
                    VStack {
                        Image(systemName: "icloud.and.arrow.up")
                            .font(.system(size: 40))
                        Text("Select Document")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 1, dash: [5]))
                    )
                }
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            Spacer()
            
            Button(action: submitDocuments) {
                if isUploading {
                    ProgressView()
                } else {
                    Text("Submit for Verification")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedFileName == nil ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .bold()
                }
            }
            .disabled(selectedFileName == nil || isUploading)
        }
        .padding()
        .navigationTitle("Upload Documents")
    }
    
    private func submitDocuments() {
        guard let _ = selectedFileName else { return }
        
        isUploading = true
        errorMessage = nil
        
        Task {
            do {
                // 1. Upload file to Storage (Simulated data)
                let simulatedFileData = Data("mock pdf content".utf8)
                let documentPath = try await fileUploadService.uploadVerificationDocument(
                    userId: UUID(), // Current user ID
                    fileData: simulatedFileData,
                    fileName: "80G_Certificate.pdf",
                    mimeType: "application/pdf"
                )
                
                // 2. Submit Verification Request
                _ = try await verificationRepo.submitVerification(
                    campaignId: campaignId,
                    documentUrls: [documentPath]
                )
                
                await MainActor.run {
                    isUploading = false
                    successMessage = "Documents submitted successfully! Your campaign is now under review."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    isUploading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        DocumentUploadView(campaignId: UUID())
    }
}
