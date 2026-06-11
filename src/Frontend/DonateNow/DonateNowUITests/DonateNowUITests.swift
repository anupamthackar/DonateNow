import XCTest

final class DonateNowUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAdminFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Navigate to Admin tab
        let adminTab = app.tabBars.buttons["Admin"]
        XCTAssertTrue(adminTab.waitForExistence(timeout: 10))
        adminTab.tap()
        
        // 2. Log in if the email field is visible
        let emailField = app.textFields["admin@donatenow.org"]
        if emailField.waitForExistence(timeout: 5) {
            emailField.tap()
            emailField.typeText("admin@donatenow.org")
            
            let passwordField = app.secureTextFields["Enter your password"]
            passwordField.tap()
            passwordField.typeText("admin123")
            
            app.buttons["Sign In"].tap()
        }
        
        // 3. Verify Dashboard loaded
        let dashboardTitle = app.navigationBars["Dashboard"]
        XCTAssertTrue(dashboardTitle.waitForExistence(timeout: 10))
        
        // 4. Navigate to Donor Payment Logs
        let logsButton = app.buttons["Donor Payment Logs"]
        if logsButton.waitForExistence(timeout: 10) {
            logsButton.tap()
        } else {
            let logsText = app.staticTexts["Donor Payment Logs"]
            XCTAssertTrue(logsText.waitForExistence(timeout: 10))
            logsText.tap()
        }
        
        // 5. Wait for the Donor Logs screen to load
        let donationLogsTitle = app.navigationBars["Donor Logs"]
        XCTAssertTrue(donationLogsTitle.waitForExistence(timeout: 10))
        
        // Sleep to let data load
        Thread.sleep(forTimeInterval: 3)
    }

    @MainActor
    func testDonationFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Ensure we are on the Donate tab
        let donateTab = app.tabBars.buttons["Donate"]
        XCTAssertTrue(donateTab.waitForExistence(timeout: 10))
        donateTab.tap()
        
        // 2. Enter Donor Details
        let nameField = app.textFields["Rahul Sharma"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 10))
        nameField.tap()
        nameField.typeText("Jane Doe")
        
        let emailField = app.textFields["rahul@example.com"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 10))
        emailField.tap()
        emailField.typeText("jane.doe@example.com")
        
        let phoneField = app.textFields["9876543210"]
        XCTAssertTrue(phoneField.waitForExistence(timeout: 10))
        phoneField.tap()
        phoneField.typeText("9999999999")
        
        // Hide keyboard by tapping somewhere else or pressing return
        app.keyboards.buttons["return"].tap()
        
        // 3. Tap Donate Button (label starts with "Donate")
        let donateButtonPredicate = NSPredicate(format: "label BEGINSWITH[c] 'Donate'")
        let donateButton = app.buttons.element(matching: donateButtonPredicate)
        XCTAssertTrue(donateButton.waitForExistence(timeout: 5))
        XCTAssertTrue(donateButton.isEnabled)
        
        donateButton.tap()
        
        // 4. Wait a few seconds to let payment initiation trigger
        Thread.sleep(forTimeInterval: 5)
    }

    @MainActor
    func testFormValidationErrors() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Ensure we are on the Donate tab
        let donateTab = app.tabBars.buttons["Donate"]
        XCTAssertTrue(donateTab.waitForExistence(timeout: 10))
        donateTab.tap()
        
        // 2. Verify Donate button is disabled initially
        let donateButtonPredicate = NSPredicate(format: "label BEGINSWITH[c] 'Donate'")
        let donateButton = app.buttons.element(matching: donateButtonPredicate)
        XCTAssertTrue(donateButton.waitForExistence(timeout: 5))
        XCTAssertFalse(donateButton.isEnabled)
        
        // 3. Enter invalid email
        let nameField = app.textFields["Rahul Sharma"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Valid Name")
        
        let emailField = app.textFields["rahul@example.com"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("invalid-email")
        
        let phoneField = app.textFields["9876543210"]
        XCTAssertTrue(phoneField.waitForExistence(timeout: 5))
        phoneField.tap()
        phoneField.typeText("9999999999")
        
        app.keyboards.buttons["return"].tap()
        
        // 4. Verify Donate button is still disabled due to invalid email
        XCTAssertFalse(donateButton.isEnabled)
    }
}
