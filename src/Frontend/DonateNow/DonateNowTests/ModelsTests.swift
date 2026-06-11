import Testing
import Foundation
@testable import DonateNow

struct ModelsTests {

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formats = [
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                "yyyy-MM-dd HH:mm:ss.SSSSSSZ",
                "yyyy-MM-dd HH:mm:ss.SSSZ",
                "yyyy-MM-dd HH:mm:ssZ",
                "yyyy-MM-dd HH:mm:ss.SSSSSSZZZZZ",
                "yyyy-MM-dd HH:mm:ss.SSSZZZZZ",
                "yyyy-MM-dd HH:mm:ssZZZZZ"
            ]
            
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateStr) {
                    return date
                }
            }
            
            // Fallback to standard ISO8601Formatter
            if let date = ISO8601DateFormatter().date(from: dateStr) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
        }
        return decoder
    }
    
    @Test func testDonationDecodingWithNumericAmount() async throws {
        let json = """
        {
            "id": "d2e049f1-88d0-4825-8d31-49aa3f5bcf05",
            "cause_id": "a3b8c2d9-1e4f-4a0b-8c1d-2e3f4a5b6c7d",
            "donor_name": "Anupam T",
            "donor_email": "anupam@gmail.com",
            "donor_phone": "9876543210",
            "amount": 19273.50,
            "currency": "INR",
            "status": "completed",
            "created_at": "2026-06-11T06:12:07.087291+00:00",
            "updated_at": "2026-06-11T06:12:07.087291+00:00"
        }
        """.data(using: .utf8)!
        
        let donation = try decoder.decode(Donation.self, from: json)
        #expect(donation.amount == 19273.50)
        #expect(donation.donorName == "Anupam T")
        #expect(donation.status == "completed")
        #expect(donation.donorPhone == "9876543210")
    }
    
    @Test func testDonationDecodingWithStringAmount() async throws {
        // PostgREST returns DECIMAL as string to prevent precision loss.
        let json = """
        {
            "id": "d2e049f1-88d0-4825-8d31-49aa3f5bcf05",
            "cause_id": "a3b8c2d9-1e4f-4a0b-8c1d-2e3f4a5b6c7d",
            "donor_name": "Anupam T",
            "donor_email": "anupam@gmail.com",
            "amount": "19273.50",
            "currency": "INR",
            "status": "completed",
            "created_at": "2026-06-11T06:12:07.087291+00:00",
            "updated_at": "2026-06-11T06:12:07.087291+00:00"
        }
        """.data(using: .utf8)!
        
        let donation = try decoder.decode(Donation.self, from: json)
        #expect(donation.amount == 19273.50)
        #expect(donation.donorName == "Anupam T")
        #expect(donation.donorPhone == nil) // Optional field
    }
    
    @Test func testCauseDecodingWithDecimalStrings() async throws {
        let json = """
        {
            "id": "a3b8c2d9-1e4f-4a0b-8c1d-2e3f4a5b6c7d",
            "title": "Help Children",
            "description": "Providing schooling items",
            "target_amount": "500000.00",
            "raised_amount": "12500.50",
            "is_active": true,
            "created_at": "2026-06-11T06:12:07.087291+00:00",
            "updated_at": "2026-06-11T06:12:07.087291+00:00"
        }
        """.data(using: .utf8)!
        
        let cause = try decoder.decode(Cause.self, from: json)
        #expect(cause.targetAmount == 500000.00)
        #expect(cause.raisedAmount == 12500.50)
        #expect(cause.isActive == true)
    }
}
