import XCTest

final class AuthFlowTests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testAnonymousUserCannotAccessAdmin() throws {
        // TC-2-081: Anonymous user access to admin views
        let app = XCUIApplication()
        app.launch()
        
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Tab bar should appear")
        
        let adminTab = tabBar.buttons["Admin"]
        if adminTab.exists {
            adminTab.tap()
            
            // Should show login view since they are anonymous
            let loginTitle = app.staticTexts["Login"]
            XCTAssertTrue(loginTitle.waitForExistence(timeout: 5), "Login screen should appear for unauthenticated user")
        }
    }
}
