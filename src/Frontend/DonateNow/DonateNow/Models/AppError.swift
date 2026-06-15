import Foundation

enum AppError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case databaseError(String)
    case authenticationError(String)
    case paymentError(String)
    case decodingError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .databaseError(let message):
            return "Database error: \(message)"
        case .authenticationError(let message):
            return "Authentication failed: \(message)"
        case .paymentError(let message):
            return "Payment error: \(message)"
        case .decodingError:
            return "Failed to decode data."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
