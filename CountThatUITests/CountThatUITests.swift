import XCTest

final class CountThatUITests: XCTestCase {

  var app: XCUIApplication!

  override func setUpWithError() throws {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launchArguments = ["--ui-testing"]
    app.launch()
  }

  override func tearDownWithError() throws {
    app = nil
  }

  // MARK: - Helpers

  @discardableResult
  func createCounter(name: String, desc: String = "", countSteps: Int = 0) -> XCUIApplication {
    app.buttons["Add Counter"].tap()
    XCTAssertTrue(app.navigationBars["New Counter"].waitForExistence(timeout: 3))

    let nameField = app.textFields.matching(identifier: "counter-name-field").firstMatch
    nameField.tap()
    nameField.typeText(name)

    if !desc.isEmpty {
      let descField = app.textFields.matching(identifier: "counter-desc-field").firstMatch
      descField.tap()
      descField.typeText(desc)
    }

    if countSteps > 0 {
      let stepper = app.steppers.firstMatch
      let increment = stepper.buttons["Increment"]
      for _ in 0..<countSteps { increment.tap() }
    }

    app.buttons["Save"].tap()
    XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 3))
    return app
  }

  // MARK: - Tests

  @MainActor
  func testEmptyStateOnFreshLaunch() {
    XCTAssertTrue(app.staticTexts["No Counters"].exists)
  }

  @MainActor
  func testCreateCounterAppearsInList() {
    createCounter(name: "Push-ups", desc: "Daily reps")

    XCTAssertTrue(app.staticTexts["Push-ups"].exists)
    XCTAssertTrue(app.staticTexts["Daily reps"].exists)

    let count = app.staticTexts.matching(identifier: "count-Push-ups").firstMatch
    XCTAssertEqual(count.label, "0")
  }

  @MainActor
  func testCreateCounterAndIncrementDecrement() {
    createCounter(name: "Steps")

    let increment = app.buttons["Increment Steps"]
    let decrement = app.buttons["Decrement Steps"]
    let count = app.staticTexts.matching(identifier: "count-Steps").firstMatch

    increment.tap()
    increment.tap()
    increment.tap()
    XCTAssertEqual(count.label, "3")

    decrement.tap()
    XCTAssertEqual(count.label, "2")
  }

  @MainActor
  func testCreateCounterWithInitialCountViaForm() {
    createCounter(name: "Laps", countSteps: 5)

    let count = app.staticTexts.matching(identifier: "count-Laps").firstMatch
    XCTAssertEqual(count.label, "5")
  }

  @MainActor
  func testCancelFormDoesNotSaveCounter() {
    app.buttons["Add Counter"].tap()
    XCTAssertTrue(app.navigationBars["New Counter"].waitForExistence(timeout: 3))

    let nameField = app.textFields.matching(identifier: "counter-name-field").firstMatch
    nameField.tap()
    nameField.typeText("Ghost Counter")

    app.buttons["Cancel"].tap()

    XCTAssertFalse(app.staticTexts["Ghost Counter"].exists)
    XCTAssertTrue(app.staticTexts["No Counters"].exists)
  }

  @MainActor
  func testSaveButtonDisabledWithEmptyName() {
    app.buttons["Add Counter"].tap()
    XCTAssertTrue(app.navigationBars["New Counter"].waitForExistence(timeout: 3))

    XCTAssertFalse(app.buttons["Save"].isEnabled)

    let nameField = app.textFields.matching(identifier: "counter-name-field").firstMatch
    nameField.tap()
    nameField.typeText("Valid Name")

    XCTAssertTrue(app.buttons["Save"].isEnabled)

    app.buttons["Cancel"].tap()
  }

  @MainActor
  func testEditExistingCounter() {
    createCounter(name: "Original")

    app.buttons["Edit Original"].tap()
    XCTAssertTrue(app.navigationBars["Edit Counter"].waitForExistence(timeout: 3))

    let nameField = app.textFields.matching(identifier: "counter-name-field").firstMatch
    nameField.tap()
    nameField.clearText()
    nameField.typeText("Renamed")

    app.buttons["Save"].tap()

    XCTAssertTrue(app.staticTexts["Renamed"].waitForExistence(timeout: 3))
    XCTAssertFalse(app.staticTexts["Original"].exists)
  }

  @MainActor
  func testSwipeToDeleteCounter() {
    createCounter(name: "Temporary")

    let row = app.staticTexts["Temporary"]
    XCTAssertTrue(row.exists)

    row.swipeLeft()
    app.buttons["Delete"].tap()

    XCTAssertTrue(app.staticTexts["Temporary"].waitForNonExistence(timeout: 3))
    XCTAssertTrue(app.staticTexts["No Counters"].waitForExistence(timeout: 3))
  }

  @MainActor
  func testCreateCounterWithTag() {
    app.buttons["Add Counter"].tap()
    XCTAssertTrue(app.navigationBars["New Counter"].waitForExistence(timeout: 3))

    let nameField = app.textFields.matching(identifier: "counter-name-field").firstMatch
    nameField.tap()
    nameField.typeText("Tagged Counter")

    let tagField = app.textFields["New tag\u{2026}"]
    tagField.tap()
    tagField.typeText("fitness")
    app.buttons["Add"].tap()

    app.buttons["Save"].tap()
    XCTAssertTrue(app.staticTexts["Tagged Counter"].waitForExistence(timeout: 3))
    XCTAssertTrue(app.staticTexts["fitness"].exists)
  }
}

// MARK: - XCUIElement helpers

extension XCUIElement {
  func clearText() {
    guard let text = value as? String, !text.isEmpty else { return }
    tap()
    let delete = String(repeating: XCUIKeyboardKey.delete.rawValue, count: text.count)
    typeText(delete)
  }
}
