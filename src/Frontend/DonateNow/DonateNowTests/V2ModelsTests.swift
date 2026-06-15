import Testing
import Foundation
@testable import DonateNow

struct V2ModelsTests {
    
    @Test("TC-2-066: Progress at 0%")
    func testProgressAtZero() async throws {
        let progress = CampaignProgress(
            id: UUID(),
            campaignId: UUID(),
            totalRaised: 0.0,
            totalDonors: 0,
            percentage: 0.0,
            snapshotDate: Date(),
            createdAt: Date()
        )
        
        #expect(progress.percentage == 0.0)
        #expect(progress.totalRaised == 0.0)
    }
    
    @Test("TC-2-067: Progress at 50%")
    func testProgressAtFifty() async throws {
        let progress = CampaignProgress(
            id: UUID(),
            campaignId: UUID(),
            totalRaised: 50000.0,
            totalDonors: 10,
            percentage: 50.0,
            snapshotDate: Date(),
            createdAt: Date()
        )
        
        #expect(progress.percentage == 50.0)
        #expect(progress.totalRaised == 50000.0)
    }
    
    @Test("TC-2-068: Progress at 100%")
    func testProgressAtHundred() async throws {
        let progress = CampaignProgress(
            id: UUID(),
            campaignId: UUID(),
            totalRaised: 100000.0,
            totalDonors: 25,
            percentage: 100.0,
            snapshotDate: Date(),
            createdAt: Date()
        )
        
        #expect(progress.percentage == 100.0)
    }
    
    @Test("TC-2-069: Progress exceeds 100%")
    func testProgressExceedsHundred() async throws {
        let progress = CampaignProgress(
            id: UUID(),
            campaignId: UUID(),
            totalRaised: 150000.0,
            totalDonors: 40,
            percentage: 150.0, // Backend might calculate raw percentage
            snapshotDate: Date(),
            createdAt: Date()
        )
        
        // Progress bar UI bounds check logic
        let clampedPercentage = min(progress.percentage, 100.0)
        #expect(clampedPercentage == 100.0)
    }
}
