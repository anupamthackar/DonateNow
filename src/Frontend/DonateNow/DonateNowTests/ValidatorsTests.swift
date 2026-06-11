import Testing
@testable import DonateNow

struct ValidatorsTests {

    @Test func testIsValidEmail() async throws {
        // Valid emails
        #expect(Validators.isValidEmail("test@example.com"))
        #expect(Validators.isValidEmail("user.name+tag@sub.domain.org"))
        #expect(Validators.isValidEmail("a@b.co"))
        
        // Invalid emails
        #expect(!Validators.isValidEmail("plainaddress"))
        #expect(!Validators.isValidEmail("@missingusername.com"))
        #expect(!Validators.isValidEmail("username@.com"))
        #expect(!Validators.isValidEmail("username@com"))
        #expect(!Validators.isValidEmail("username@sub.domain.c"))
    }
    
    @Test func testIsValidPhone() async throws {
        // Valid phones
        #expect(Validators.isValidPhone("")) // Phone is optional
        #expect(Validators.isValidPhone("9876543210"))
        #expect(Validators.isValidPhone("1234567890"))
        
        // Invalid phones
        #expect(!Validators.isValidPhone("123"))
        #expect(!Validators.isValidPhone("12345678901")) // 11 digits
        #expect(!Validators.isValidPhone("abc123def4"))
        #expect(!Validators.isValidPhone(" 9876543210 ")) // Leading/trailing spaces
    }
    
    @Test func testIsValidAmount() async throws {
        // Valid amounts
        #expect(Validators.isValidAmount("1"))
        #expect(Validators.isValidAmount("500"))
        #expect(Validators.isValidAmount("100000"))
        #expect(Validators.isValidAmount("12345.67"))
        
        // Invalid amounts
        #expect(!Validators.isValidAmount("0"))
        #expect(!Validators.isValidAmount("-10"))
        #expect(!Validators.isValidAmount("100001"))
        #expect(!Validators.isValidAmount("abc"))
        #expect(!Validators.isValidAmount(""))
    }
}
