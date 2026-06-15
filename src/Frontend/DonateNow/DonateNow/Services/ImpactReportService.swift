import Foundation
import Supabase

class ImpactReportService {
    private let supabase = SupabaseManager.shared.client
    
    // Fetch existing reports
    func getReports(campaignId: UUID) async throws -> [ImpactReport] {
        return try await supabase
            .from("impact_reports")
            .select()
            .eq("campaign_id", value: campaignId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    // Request a new AI-generated report via Edge Function
    // (We mock the edge function call here for the prototype, returning a local struct or calling Supabase functions)
    func generateReport(campaignId: UUID, startDate: Date?, endDate: Date?) async throws -> ImpactReport {
        // In a real app, you invoke the Edge Function:
        /*
        let params = ["campaignId": campaignId.uuidString, ...]
        let response = try await supabase.functions.invoke("generate-impact-report", options: .init(body: params))
        return try JSONDecoder().decode(ImpactReportResponse.self, from: response).report
        */
        
        // Mocked response for prototype
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        let statsJson = """
        {"totalDonors": 45, "totalRaisedPeriod": 15000, "avgDonation": 333}
        """
        
        return ImpactReport(
            id: UUID(),
            campaignId: campaignId,
            content: "We are thrilled to share that over the last period, 45 generous donors came together to raise ₹15,000 for our cause. Your continued support is what makes our mission possible. Thank you for standing by us as we work towards our overall goal!",
            statisticsJson: statsJson,
            dateRangeStart: startDate ?? Date().addingTimeInterval(-86400 * 30),
            dateRangeEnd: endDate ?? Date(),
            generatedAt: Date(),
            createdAt: Date()
        )
    }
}
