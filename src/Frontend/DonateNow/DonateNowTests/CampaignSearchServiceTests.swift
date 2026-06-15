import Testing
import Foundation
@testable import DonateNow

struct CampaignSearchServiceTests {
    
    // In a real environment, CampaignSearchService fetches from Supabase.
    // However, since we mock it in tests usually, we'll write logic tests here.
    
    @Test("TC-2-060: Search campaigns by title")
    func testSearchCampaignsByTitle() async throws {
        let mockService = MockCampaignSearchService()
        
        let campaign1 = DonationProfile(
            id: UUID(),
            creatorId: UUID(),
            title: "Help the Oceans",
            description: "Clean the beach",
            category: "Environment",
            targetAmount: 10000,
            raisedAmount: 0,
            imageUrl: nil,
            verificationStatus: .verified,
            isActive: true,
            startDate: Date(),
            endDate: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let campaign2 = DonationProfile(
            id: UUID(),
            creatorId: UUID(),
            title: "Build a School",
            description: "Education for all",
            category: "Education",
            targetAmount: 50000,
            raisedAmount: 0,
            imageUrl: nil,
            verificationStatus: .verified,
            isActive: true,
            startDate: Date(),
            endDate: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        mockService.campaignsToReturn = [campaign1, campaign2]
        
        let results = try await mockService.searchCampaigns(query: "Ocean")
        #expect(results.count == 1)
        #expect(results.first?.title == "Help the Oceans")
        
        let emptyResults = try await mockService.searchCampaigns(query: "Hospital")
        #expect(emptyResults.isEmpty) // TC-2-061: Empty state
    }
}
