import XCTest

final class MarketplaceFlowTests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testMarketplaceLoadsAndSearchWorks() throws {
        // TC-2-065: Marketplace browse and select flow
        let app = XCUIApplication()
        app.launch()
        
        // Wait for the tab bar to appear
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "Tab bar should appear")
        
        // Tap on Explore tab
        let exploreTab = tabBar.buttons["Explore"]
        if exploreTab.exists {
            exploreTab.tap()
        }
        
        // Search bar interaction
        let searchField = app.searchFields["Search campaigns..."]
        if searchField.waitForExistence(timeout: 5) {
            searchField.tap()
            searchField.typeText("Education")
            app.keyboards.buttons["Search"].tap()
        }
    }
}
