import XCTest

final class CountThatSnapshotTests: XCTestCase {

  // swiftlint:disable:next implicitly_unwrapped_optional
  var app: XCUIApplication!

  @MainActor
  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = ["--ui-testing"]
    setupSnapshot(app)
    app.launch()
  }

  override func tearDownWithError() throws {
    app = nil
  }

  @MainActor
  func testCaptureScreenshots() {
    app.createCounter(name: "Cat gets fed early", desc: "(≽^•˕•^≼)", count: 6)
    app.createCounter(name: "Running", desc: "Miles this year", count: 201)
    snapshot("01Counters")

    app.buttons["Add Counter"].tap()
    XCTAssertTrue(app.navigationBars["New Counter"].waitForExistence(timeout: 3))

    let nameField = app.textFields.matching(identifier: "counter-name-field").firstMatch
    nameField.tap()
    nameField.typeText("Reading ")

    let descField = app.textFields.matching(identifier: "counter-desc-field").firstMatch
    descField.tap()
    descField.typeText("Books this year")
    snapshot("02AddCounter")

    app.buttons["Save"].tap()
    XCTAssertTrue(app.staticTexts["Reading"].waitForExistence(timeout: 3))
    snapshot("03CounterAdded")
  }
}
