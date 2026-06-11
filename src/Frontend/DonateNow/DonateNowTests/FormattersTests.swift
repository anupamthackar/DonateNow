import Testing
import Foundation
@testable import DonateNow

struct FormattersTests {

    @Test func testFormatCurrency() async throws {
        // Test standard Indian currency formatting (INR)
        let formattedSmall = Formatters.formatCurrency(amount: 500.0)
        // Clean whitespaces to ignore non-breaking spaces (U+00A0 or U+202F) differences across iOS versions
        let cleanedSmall = formattedSmall.replacingOccurrences(of: "\u{00A0}", with: " ").replacingOccurrences(of: "\u{202F}", with: " ")
        #expect(cleanedSmall.contains("₹"))
        #expect(cleanedSmall.contains("500.00"))
        
        let formattedLarge = Formatters.formatCurrency(amount: 123456.78)
        let cleanedLarge = formattedLarge.replacingOccurrences(of: "\u{00A0}", with: " ").replacingOccurrences(of: "\u{202F}", with: " ")
        #expect(cleanedLarge.contains("₹"))
        #expect(cleanedLarge.contains("1,23,456.78") || cleanedLarge.contains("123,456.78"))
    }
    
    @Test func testFormatDate() async throws {
        // Test date formatting
        let date = Date(timeIntervalSince1970: 1718089200) // Some static timestamp
        let formattedDate = Formatters.formatDate(date)
        #expect(!formattedDate.isEmpty)
    }
}
