import Foundation
import Combine
import SwiftUI

@MainActor
class AdminAuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    
    var isFormValid: Bool {
        Validators.isValidEmail(email) && password.count >= 6
    }
    
    func login() async -> Bool {
        guard isFormValid else { return false }
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signIn(email: email, password: password)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
