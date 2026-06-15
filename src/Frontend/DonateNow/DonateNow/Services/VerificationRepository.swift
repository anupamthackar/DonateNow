import Foundation
import Supabase

class VerificationRepository {
    private let supabase = SupabaseManager.shared.client
    
    private struct SubmitRequest: Encodable {
        let campaign_id: String
        let documents_url: [String]
        let status: String
    }
    
    // Submit a campaign for verification
    func submitVerification(campaignId: UUID, documentUrls: [String]) async throws -> VerificationRequest {
        // 1. Create the verification request
        let req = SubmitRequest(campaign_id: campaignId.uuidString, documents_url: documentUrls, status: "pending")
        
        let request: VerificationRequest = try await supabase
            .from("verification_requests")
            .insert(req)
            .select()
            .single()
            .execute()
            .value
            
        // 2. Update the campaign status
        struct UpdateStatusReq: Encodable { let verification_status: String }
        try await supabase
            .from("donation_profiles")
            .update(UpdateStatusReq(verification_status: "pending"))
            .eq("id", value: campaignId.uuidString)
            .execute()
            
        return request
    }
    
    // Get verification queue (Admin)
    func getVerificationQueue() async throws -> [VerificationRequest] {
        return try await supabase
            .from("verification_requests")
            .select("*, donation_profiles!campaign_id(title, creator_id)")
            .eq("status", value: "pending")
            .order("submitted_at", ascending: true)
            .execute()
            .value
    }
    
    private struct ApproveRequest: Encodable {
        let status: String
        let reviewer_id: String
        let reviewed_at: String
    }
    
    // Approve a campaign (Admin)
    func approveCampaign(requestId: UUID, campaignId: UUID, adminId: UUID) async throws {
        let req = ApproveRequest(status: "approved", reviewer_id: adminId.uuidString, reviewed_at: Date().ISO8601Format())
        try await supabase
            .from("verification_requests")
            .update(req)
            .eq("id", value: requestId.uuidString)
            .execute()
            
        struct UpdateStatusReq: Encodable { let verification_status: String }
        try await supabase
            .from("donation_profiles")
            .update(UpdateStatusReq(verification_status: "verified"))
            .eq("id", value: campaignId.uuidString)
            .execute()
    }
    
    private struct RejectRequest: Encodable {
        let status: String
        let reviewer_id: String
        let review_notes: String
        let reviewed_at: String
    }
    
    // Reject a campaign (Admin)
    func rejectCampaign(requestId: UUID, campaignId: UUID, adminId: UUID, reason: String) async throws {
        let req = RejectRequest(status: "rejected", reviewer_id: adminId.uuidString, review_notes: reason, reviewed_at: Date().ISO8601Format())
        try await supabase
            .from("verification_requests")
            .update(req)
            .eq("id", value: requestId.uuidString)
            .execute()
            
        struct UpdateStatusReq: Encodable { let verification_status: String }
        try await supabase
            .from("donation_profiles")
            .update(UpdateStatusReq(verification_status: "rejected"))
            .eq("id", value: campaignId.uuidString)
            .execute()
    }
    
    // Get latest verification status for a creator's campaign
    func getLatestVerification(campaignId: UUID) async throws -> VerificationRequest? {
        let requests: [VerificationRequest] = try await supabase
            .from("verification_requests")
            .select()
            .eq("campaign_id", value: campaignId.uuidString)
            .order("submitted_at", ascending: false)
            .limit(1)
            .execute()
            .value
            
        return requests.first
    }
}
