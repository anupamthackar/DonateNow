import Foundation
import Combine

@MainActor
class VerificationViewModel: ObservableObject {
    @Published var requests: [VerificationRequest] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    
    var fetchQueueAction: () async throws -> [VerificationRequest]
    
    init(fetchQueueAction: @escaping () async throws -> [VerificationRequest]) {
        self.fetchQueueAction = fetchQueueAction
    }
    
    func loadQueue() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await fetchQueueAction()
            requests = fetched
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
