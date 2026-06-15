import Testing
import Foundation
@testable import DonateNow

@MainActor
struct VerificationViewModelTests {
    
    func mockFetchAction(shouldSucceed: Bool, empty: Bool = false) -> () async throws -> [VerificationRequest] {
        return {
            if shouldSucceed {
                if empty { return [] }
                return [
                    VerificationRequest(id: UUID(), campaignId: UUID(), documentsUrl: [], status: .pending, reviewerId: nil, reviewNotes: nil, submittedAt: Date(), reviewedAt: nil, createdAt: Date()),
                    VerificationRequest(id: UUID(), campaignId: UUID(), documentsUrl: [], status: .pending, reviewerId: nil, reviewNotes: nil, submittedAt: Date(), reviewedAt: nil, createdAt: Date())
                ]
            } else {
                throw AppError.networkError(NSError(domain: "", code: -1, userInfo: nil))
            }
        }
    }
    
    @Test("TC-2-019: Verification queue shows all pending")
    func testFetchQueueSuccess() async throws {
        let vm = VerificationViewModel(fetchQueueAction: mockFetchAction(shouldSucceed: true))
        
        await vm.loadQueue()
        #expect(vm.isLoading == false)
        #expect(vm.requests.count == 2)
        #expect(vm.errorMessage == nil)
    }
    
    @Test("TC-2-019: Empty queue state")
    func testFetchQueueEmpty() async throws {
        let vm = VerificationViewModel(fetchQueueAction: mockFetchAction(shouldSucceed: true, empty: true))
        
        await vm.loadQueue()
        #expect(vm.isLoading == false)
        #expect(vm.requests.isEmpty)
        #expect(vm.errorMessage == nil)
    }
    
    @Test("TC-2-019: Queue fetch error")
    func testFetchQueueError() async throws {
        let vm = VerificationViewModel(fetchQueueAction: mockFetchAction(shouldSucceed: false))
        
        await vm.loadQueue()
        #expect(vm.isLoading == false)
        #expect(vm.requests.isEmpty)
        #expect(vm.errorMessage != nil)
    }
}
