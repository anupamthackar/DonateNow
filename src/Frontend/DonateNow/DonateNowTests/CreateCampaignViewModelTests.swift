import Testing
import Foundation
@testable import DonateNow

@MainActor
struct CreateCampaignViewModelTests {
    
    func createMockAction(shouldSucceed: Bool = true) -> (UUID, String, String, String, Decimal, String?) async throws -> DonationProfile {
        return { _, _, _, _, _, _ in
            if shouldSucceed {
                return DonationProfile(id: UUID(), creatorId: UUID(), title: "Test", description: "Test", category: "Edu", targetAmount: 100, raisedAmount: 0, imageUrl: nil, verificationStatus: .draft, isActive: true, startDate: Date(), endDate: nil, createdAt: Date(), updatedAt: Date())
            } else {
                throw AppError.networkError(NSError(domain: "", code: -1, userInfo: nil))
            }
        }
    }
    
    @Test("TC-2-002: Create campaign with empty title")
    func testEmptyTitle() async throws {
        let vm = CreateCampaignViewModel(createCampaignAction: createMockAction())
        vm.title = ""
        vm.description = "Valid description"
        vm.targetAmount = "100"
        
        let result = await vm.submitCampaign()
        #expect(result == false)
        #expect(vm.errorMessage == "Title cannot be empty.")
    }
    
    @Test("TC-2-003: Create campaign with empty description")
    func testEmptyDescription() async throws {
        let vm = CreateCampaignViewModel(createCampaignAction: createMockAction())
        vm.title = "Valid Title"
        vm.description = ""
        vm.targetAmount = "100"
        
        let result = await vm.submitCampaign()
        #expect(result == false)
        #expect(vm.errorMessage == "Description cannot be empty.")
    }
    
    @Test("TC-2-004: Create campaign with zero target amount")
    func testZeroTargetAmount() async throws {
        let vm = CreateCampaignViewModel(createCampaignAction: createMockAction())
        vm.title = "Valid Title"
        vm.description = "Valid Description"
        vm.targetAmount = "0"
        
        let result = await vm.submitCampaign()
        #expect(result == false)
        #expect(vm.errorMessage == "Please enter a valid target amount greater than 0.")
    }
    
    @Test("TC-2-005: Create campaign with negative target")
    func testNegativeTargetAmount() async throws {
        let vm = CreateCampaignViewModel(createCampaignAction: createMockAction())
        vm.title = "Valid Title"
        vm.description = "Valid Description"
        vm.targetAmount = "-500"
        
        let result = await vm.submitCampaign()
        #expect(result == false)
        #expect(vm.errorMessage == "Please enter a valid target amount greater than 0.")
    }
    
    @Test("TC-2-001: Create campaign with valid data")
    func testValidCampaignCreation() async throws {
        let vm = CreateCampaignViewModel(createCampaignAction: createMockAction())
        vm.title = "Valid Title"
        vm.description = "Valid Description"
        vm.targetAmount = "1000"
        
        let result = await vm.submitCampaign()
        #expect(result == true)
        #expect(vm.errorMessage == nil)
    }
}
