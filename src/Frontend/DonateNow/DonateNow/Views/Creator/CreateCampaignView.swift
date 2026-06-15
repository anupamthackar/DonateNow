import SwiftUI
import PhotosUI
import Supabase

struct CreateCampaignView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: String = "Education"
    @State private var targetAmount: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    @State private var createdCampaign: DonationProfile? = nil
    @State private var showCampaignDetail = false
    
    // Image picker state
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var uploadedImageUrl: String? = nil
    
    let categories = ["Education", "Medical", "Environment", "Community", "Disaster Relief", "Animals"]
    
    private let repository = CampaignRepository()
    @StateObject private var authService = AuthService.shared
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Campaign Details")) {
                    TextField("Campaign Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    
                    TextField("Target Amount (INR)", text: $targetAmount)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Campaign Image")) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        HStack {
                            Image(systemName: selectedImageData != nil ? "checkmark.circle.fill" : "photo.on.rectangle.angled")
                                .foregroundColor(selectedImageData != nil ? .green : Color.theme.primary)
                            Text(selectedImageData != nil ? "Image Selected ✓" : "Choose Cover Image")
                                .foregroundColor(.primary)
                        }
                    }
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                    
                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 150)
                            .clipped()
                            .cornerRadius(8)
                    }
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(height: 150)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Button(action: submitCampaign) {
                    if isSubmitting {
                        HStack {
                            ProgressView()
                            Text("Creating...")
                                .padding(.leading, 8)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        Text("Create Draft Campaign")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(isSubmitting || title.isEmpty || targetAmount.isEmpty || description.isEmpty)
            }
            .navigationTitle("New Campaign")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .navigationDestination(isPresented: $showCampaignDetail) {
                if let campaign = createdCampaign {
                    CampaignDetailView(campaign: campaign)
                }
            }
        }
    }
    
    private func submitCampaign() {
        guard let amount = Decimal(string: targetAmount), amount > 0 else {
            errorMessage = "Please enter a valid target amount."
            return
        }
        
        guard let userId = authService.currentUser?.id else {
            errorMessage = "You must be logged in to create a campaign."
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                // Upload image if selected
                var imageUrl: String? = nil
                if let imageData = selectedImageData {
                    imageUrl = try await uploadImage(data: imageData, userId: userId)
                }
                
                let profile = try await repository.createCampaign(
                    creatorId: userId,
                    title: title,
                    description: description,
                    category: category,
                    targetAmount: amount,
                    imageUrl: imageUrl
                )
                
                await MainActor.run {
                    isSubmitting = false
                    createdCampaign = profile
                    showCampaignDetail = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func uploadImage(data: Data, userId: UUID) async throws -> String {
        let supabase = SupabaseManager.shared.client
        let fileName = "\(userId.uuidString)/\(UUID().uuidString).jpg"
        
        try await supabase.storage
            .from("campaign-images")
            .upload(
                path: fileName,
                file: data,
                options: .init(contentType: "image/jpeg")
            )
        
        let publicUrl = try supabase.storage
            .from("campaign-images")
            .getPublicURL(path: fileName)
        
        return publicUrl.absoluteString
    }
}

#Preview {
    CreateCampaignView()
}
