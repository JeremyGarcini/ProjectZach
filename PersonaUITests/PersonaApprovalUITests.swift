import XCTest

/// End-to-end coverage of every state the recording has to show, including the
/// ones that are easy to skip: cancelling mid-flight, failing, retrying, undoing.
final class PersonaApprovalUITests: XCTestCase {

    @MainActor
    func testLowStakesApproveThenUndo() {
        let app = launchApp()

        app.buttons["Move to 8:00 PM"].tap()
        XCTAssertTrue(app.staticTexts["Moved to 8:00 PM"].waitForExistence(timeout: 4))

        app.buttons["Undo"].tap()
        XCTAssertTrue(app.staticTexts["Back to 7:30 PM"].waitForExistence(timeout: 2))

        app.buttons["Back to the request"].tap()
        XCTAssertTrue(app.staticTexts["Move dinner to 8:00 PM"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testLowStakesDeclineLeavesEverythingAlone() {
        let app = launchApp()

        app.buttons["Not now"].tap()
        XCTAssertTrue(app.staticTexts["Dinner stays at 7:30 PM"].waitForExistence(timeout: 2))

        app.buttons["Ask me again"].tap()
        XCTAssertTrue(app.staticTexts["Move dinner to 8:00 PM"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testEditingTheTimeUpdatesTheRequestWithoutApprovingIt() {
        let app = launchApp()

        app.buttons["Edit"].tap()
        app.buttons["8:30 PM"].tap()
        app.buttons["Save"].tap()

        // Saving must return to the request, never straight into the action.
        XCTAssertTrue(app.staticTexts["Move dinner to 8:30 PM"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Move to 8:30 PM"].exists)
    }

    @MainActor
    func testHighStakesHoldToSendFailsThenRetriesThenUndoes() {
        let app = launchApp()

        app.buttons["High stakes"].tap()
        app.buttons["Review message"].tap()
        XCTAssertTrue(app.staticTexts["This goes to Daniel"].waitForExistence(timeout: 2))

        // A real touch, held. A tap would release instantly, which is exactly the
        // gesture this control is built to reject.
        app.buttons["Hold to send"].press(forDuration: 1.6)
        XCTAssertTrue(app.staticTexts["Couldn’t send"].waitForExistence(timeout: 4))

        app.buttons["Try again"].tap()
        XCTAssertTrue(app.staticTexts["Sent to Daniel"].waitForExistence(timeout: 4))

        app.buttons["Undo"].tap()
        XCTAssertTrue(app.staticTexts["Message unsent"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testAnOperationCanBeCancelledWhileItRuns() {
        let app = launchApp()

        app.buttons["Move to 8:00 PM"].tap()

        // The operation is genuinely in flight, so the control has to be waited
        // for rather than assumed — and reached before the operation finishes.
        let cancel = app.buttons["Cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Calling Bar Pitti"].exists)

        cancel.tap()
        XCTAssertTrue(app.staticTexts["Move dinner to 8:00 PM"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testHeaderStaysPinnedWhileTheRequestScrollsUnderIt() {
        let app = launchApp()
        settle(); attach(app.screenshot(), named: "01-low-stakes-at-rest")

        app.swipeUp()
        settle(); attach(app.screenshot(), named: "02-low-stakes-scrolled-under-blur")

        XCTAssertTrue(app.staticTexts["Mira"].exists)
        XCTAssertTrue(app.buttons["Low stakes"].exists)
    }

    @MainActor
    func testCapturesEveryStateForReview() {
        let app = launchApp()

        app.buttons["Edit"].tap()
        settle(); attach(app.screenshot(), named: "03-edit-reservation")
        app.buttons["Save"].tap()

        app.buttons["Move to 8:00 PM"].tap()
        settle(); attach(app.screenshot(), named: "04-in-progress")
        XCTAssertTrue(app.staticTexts["Moved to 8:00 PM"].waitForExistence(timeout: 4))
        settle(); attach(app.screenshot(), named: "05-succeeded")

        app.buttons["Undo"].tap()
        XCTAssertTrue(app.staticTexts["Back to 7:30 PM"].waitForExistence(timeout: 2))
        settle(); attach(app.screenshot(), named: "06-undone")
        app.buttons["Back to the request"].tap()

        app.buttons["Not now"].tap()
        XCTAssertTrue(app.staticTexts["Dinner stays at 7:30 PM"].waitForExistence(timeout: 2))
        settle(); attach(app.screenshot(), named: "07-declined")
        app.buttons["Ask me again"].tap()

        app.buttons["High stakes"].tap()
        settle(); attach(app.screenshot(), named: "08-high-stakes-at-rest")
        app.swipeUp()
        settle(); attach(app.screenshot(), named: "09-high-stakes-scrolled")
        app.swipeDown()

        app.buttons["Edit"].tap()
        settle(); attach(app.screenshot(), named: "10-edit-message")
        app.buttons["Close"].tap()

        app.buttons["Review message"].tap()
        XCTAssertTrue(app.staticTexts["This goes to Daniel"].waitForExistence(timeout: 2))
        settle(); attach(app.screenshot(), named: "11-review")

        // A real touch, held: XCUITest taps release instantly, which is exactly
        // the gesture this control is designed to reject.
        app.buttons["Hold to send"].press(forDuration: 1.6)
        XCTAssertTrue(app.staticTexts["Couldn’t send"].waitForExistence(timeout: 4))
        settle(); attach(app.screenshot(), named: "12-failed")

        app.buttons["Try again"].tap()
        XCTAssertTrue(app.staticTexts["Sent to Daniel"].waitForExistence(timeout: 4))
        settle(); attach(app.screenshot(), named: "13-sent")
    }

    // MARK: Helpers

    @MainActor
    private func launchApp() -> XCUIApplication {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        return app
    }

    /// Screenshots are for reviewing the design, so they have to be taken once
    /// the transition has settled — `waitForExistence` returns on the first frame
    /// a view appears, which is mid-animation.
    private func settle() {
        Thread.sleep(forTimeInterval: 0.7)
    }

    private func attach(_ screenshot: XCUIScreenshot, named name: String) {
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
