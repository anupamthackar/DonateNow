import Foundation
@testable import DonateNow

class MockCampaignSearchService {
    var campaignsToReturn: [DonationProfile] = []
    
    func searchCampaigns(query: String) async throws -> [DonationProfile] {
        if query.isEmpty { return campaignsToReturn }
        return campaignsToReturn.filter { $0.title.lowercased().contains(query.lowercased()) }
    }
}
