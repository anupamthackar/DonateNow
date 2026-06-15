import Foundation
import Supabase

class FileUploadService {
    private let supabase = SupabaseManager.shared.client
    
    // Upload a document for verification
    func uploadVerificationDocument(userId: UUID, fileData: Data, fileName: String, mimeType: String) async throws -> String {
        let path = "\(userId.uuidString)/\(UUID().uuidString)-\(fileName)"
        
        // Basic extension parsing. A real app might rely on UTType
        
        try await supabase.storage
            .from("documents")
            .upload(
                path: path,
                file: fileData,
                options: .init(contentType: mimeType)
            )
            
        return path
    }
    
    // Upload a campaign cover image
    func uploadCampaignImage(campaignId: UUID, fileData: Data, mimeType: String = "image/jpeg") async throws -> String {
        let path = "campaigns/\(campaignId.uuidString)/cover-\(UUID().uuidString).jpg"
        
        try await supabase.storage
            .from("campaign-images")
            .upload(
                path: path,
                file: fileData,
                options: .init(contentType: mimeType)
            )
            
        return path
    }
    
    // Get public URL for an image
    func getPublicImageUrl(path: String) -> URL {
        return try! supabase.storage
            .from("campaign-images")
            .getPublicURL(path: path)
    }
}
