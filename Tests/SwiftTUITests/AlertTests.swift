//
//  AlertTests.swift
//  SwiftTUITests
//
//  Tests for Alert component with modal-like display and dismiss functionality
//

import XCTest
import yoga

@testable import SwiftTUI

final class AlertTests: SwiftTUITestCase {

  // MARK: - Helper Methods

  /// Helper method to test alert output directly since TestRenderer might not work with Alert
  private func renderAlert(_ alert: Alert) -> String {
    let alertLayoutView = alert._layoutView
    guard let cellLayoutView = alertLayoutView as? CellLayoutView else {
      XCTFail("AlertLayoutView should implement CellLayoutView")
      return ""
    }

    // FocusManagerの状態をリセットしてクリーンな状態で開始
    FocusManager.shared.reset()

    var testBuffer = CellBuffer(width: 50, height: 20)
    cellLayoutView.paintCells(origin: (0, 0), into: &testBuffer)
    let testLines = testBuffer.toANSILines()
    let result = testLines.map { line in
      // Strip ANSI
      let pattern = "\u{1B}\\[[0-9;]*m"
      let regex = try! NSRegularExpression(pattern: pattern, options: [])
      let range = NSRange(location: 0, length: line.utf16.count)
      return regex.stringByReplacingMatches(in: line, options: [], range: range, withTemplate: "")
    }.joined(separator: "\n")

    // テスト後にFocusManagerをクリア
    FocusManager.shared.reset()

    return result
  }

  /// Helper method to render view with alert modifier using TestRenderer
  private func renderWithAlertModifier<V: View>(_ view: V) -> String {
    return TestRenderer.render(view, width: 50, height: 20)
  }

  // MARK: - Basic Display Tests

  func testAlertBasicDisplay() {
    // Given - Alert with title only
    var dismissed = false
    let alert = Alert(
      title: "Test Alert",
      dismiss: {
        dismissed = true
      })

    // When
    let output = renderAlert(alert)

    // Then - Should show alert structure with title
    XCTAssertTrue(output.contains("Test Alert"), "Should show alert title")
    XCTAssertTrue(output.contains("╔"), "Should show top left corner")
    XCTAssertTrue(output.contains("╗"), "Should show top right corner")
    XCTAssertTrue(output.contains("╚"), "Should show bottom left corner")
    XCTAssertTrue(output.contains("╝"), "Should show bottom right corner")
    XCTAssertTrue(output.contains("[ OK ]"), "Should show OK button")
  }

  func testAlertWithMessage() {
    // Given - Alert with title and message
    var dismissed = false
    let alert = Alert(
      title: "Warning", message: "This is a warning message",
      dismiss: {
        dismissed = true
      })

    // When
    let output = renderAlert(alert)

    // Then - Should show both title and message
    XCTAssertTrue(output.contains("Warning"), "Should show alert title")
    XCTAssertTrue(output.contains("This is a warning message"), "Should show message")
    XCTAssertTrue(output.contains("╟"), "Should show separator line")
    XCTAssertTrue(output.contains("╢"), "Should show separator line end")
    XCTAssertTrue(output.contains("[ OK ]"), "Should show OK button")
  }

  func testAlertBorderAndColors() {
    // Given - Alert to check border structure
    var dismissed = false
    let alert = Alert(
      title: "Error",
      dismiss: {
        dismissed = true
      })

    // When
    let output = renderAlert(alert)

    // Then - Should have complete border structure
    // Top border
    XCTAssertTrue(output.contains("╔"), "Should have top left corner")
    XCTAssertTrue(output.contains("═"), "Should have horizontal double lines")
    XCTAssertTrue(output.contains("╗"), "Should have top right corner")

    // Side borders
    XCTAssertTrue(output.contains("║"), "Should have vertical double lines")

    // Bottom border
    XCTAssertTrue(output.contains("╚"), "Should have bottom left corner")
    XCTAssertTrue(output.contains("╝"), "Should have bottom right corner")
  }

  func testAlertCenterAlignment() {
    // Given - Alert with short title to test centering
    var dismissed = false
    let alert = Alert(
      title: "OK",
      dismiss: {
        dismissed = true
      })

    // When
    let output = renderAlert(alert)
    let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }

    // Then - Title should be centered (check for padding on both sides)
    if let titleLine = lines.first(where: { $0.contains("OK") && $0.contains("║") }) {
      let beforeOK = titleLine.components(separatedBy: "OK").first ?? ""
      let afterOK = titleLine.components(separatedBy: "OK").last ?? ""
      // Both sides should have padding (spaces)
      XCTAssertTrue(beforeOK.contains(" "), "Should have padding before title")
      XCTAssertTrue(afterOK.contains(" "), "Should have padding after title")
    }
  }

  func testAlertOKButton() {
    // Given - Alert to test OK button display
    var dismissed = false
    let alert = Alert(
      title: "Confirm",
      dismiss: {
        dismissed = true
      })

    // When
    let output = renderAlert(alert)
    let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }

    // Then - Should show centered OK button
    XCTAssertTrue(output.contains("[ OK ]"), "Should show OK button")

    // Check button is centered
    if let buttonLine = lines.first(where: { $0.contains("[ OK ]") }) {
      let beforeButton = buttonLine.components(separatedBy: "[ OK ]").first ?? ""
      let afterButton = buttonLine.components(separatedBy: "[ OK ]").last ?? ""
      // Both sides should have padding
      XCTAssertTrue(beforeButton.contains(" "), "Should have padding before button")
      XCTAssertTrue(afterButton.contains(" "), "Should have padding after button")
    }
  }

  // MARK: - Binding State Management Tests

  func testAlertModifierShowing() {
    // Given - View with alert modifier where isPresented is true
    struct TestView: View {
      @State var showAlert = true

      var body: some View {
        Text("Content")
          .alert("Test Alert", isPresented: $showAlert)
      }
    }

    // When
    let output = renderWithAlertModifier(TestView())

    // Then - Should show alert, not content
    XCTAssertTrue(output.contains("Test Alert"), "Should show alert title")
    XCTAssertTrue(output.contains("[ OK ]"), "Should show OK button")
    XCTAssertFalse(output.contains("Content"), "Should not show content when alert is visible")
  }

  func testAlertModifierHidden() {
    // Given - View with alert modifier where isPresented is false
    struct TestView: View {
      @State var showAlert = false

      var body: some View {
        Text("Content")
          .alert("Test Alert", isPresented: $showAlert)
      }
    }

    // When
    let output = renderWithAlertModifier(TestView())

    // Then - Should show content, not alert
    XCTAssertTrue(output.contains("Content"), "Should show content")
    XCTAssertFalse(output.contains("Test Alert"), "Should not show alert")
    XCTAssertFalse(output.contains("[ OK ]"), "Should not show OK button")
  }

  func testAlertDismissBinding() {
    // Given - Alert with dismiss action
    var wasDisssed = false
    let alert = Alert(
      title: "Dismiss Test",
      dismiss: {
        wasDisssed = true
      })

    // When - Simulate dismiss action
    if let layoutView = alert._layoutView as? AlertLayoutView {
      layoutView.handleKeyEvent(KeyboardEvent(key: .enter))
    }

    // Then
    XCTAssertTrue(wasDisssed, "Dismiss action should be called")
  }

  func testAlertMultipleIndependent() {
    // Given - View with multiple independent alerts
    struct TestView: View {
      @State var showInfo = false
      @State var showWarning = true

      var body: some View {
        VStack {
          Text("Info")
            .alert("Information", isPresented: $showInfo)

          Text("Warning")
            .alert("Warning!", isPresented: $showWarning)
        }
      }
    }

    // When
    let output = renderWithAlertModifier(TestView())

    // Then - Should show warning alert (last one wins in current implementation)
    XCTAssertTrue(output.contains("Warning!"), "Should show warning alert")
    XCTAssertFalse(output.contains("Information"), "Should not show info alert")
  }

  // MARK: - Modifier Behavior Tests

  func testAlertOverContent() {
    // Given - Complex content with alert
    struct TestView: View {
      @State var showAlert = true

      var body: some View {
        VStack {
          Text("Title")
            .bold()
          Text("Content line 1")
          Text("Content line 2")
        }
        .padding()
        .border()
        .alert("Override", isPresented: $showAlert)
      }
    }

    // When
    let output = renderWithAlertModifier(TestView())

    // Then - Should only show alert
    XCTAssertTrue(output.contains("Override"), "Should show alert")
    XCTAssertFalse(output.contains("Title"), "Should not show content title")
    XCTAssertFalse(output.contains("Content line 1"), "Should not show content")
  }

  func testAlertContentSwitch() {
    // Given - View that can switch between content and alert
    struct TestView: View {
      let showAlert: Bool

      var body: some View {
        Text("Normal Content")
          .padding()
          .alert("Alert!", isPresented: .constant(showAlert))
      }
    }

    // When - Test both states
    let contentOutput = renderWithAlertModifier(TestView(showAlert: false))
    let alertOutput = renderWithAlertModifier(TestView(showAlert: true))

    // Then
    XCTAssertTrue(
      contentOutput.contains("Normal Content"), "Should show content when alert is hidden")
    XCTAssertFalse(contentOutput.contains("Alert!"), "Should not show alert when hidden")

    XCTAssertTrue(alertOutput.contains("Alert!"), "Should show alert when visible")
    XCTAssertFalse(
      alertOutput.contains("Normal Content"), "Should not show content when alert is visible")
  }

  func testAlertNestedViews() {
    // Given - Nested views with alert at different levels
    struct ChildView: View {
      @Binding var showAlert: Bool

      var body: some View {
        Button("Show Alert") {
          showAlert = true
        }
      }
    }

    struct ParentView: View {
      @State var showAlert = true

      var body: some View {
        VStack {
          Text("Parent")
          ChildView(showAlert: $showAlert)
        }
        .alert("Parent Alert", isPresented: $showAlert)
      }
    }

    // When
    let output = renderWithAlertModifier(ParentView())

    // Then
    XCTAssertTrue(output.contains("Parent Alert"), "Should show alert")
    // Check that VStack content is not shown (Parent text should only appear in alert title)
    let lines = output.components(separatedBy: "\n")
    let parentTextLines = lines.filter { $0.contains("Parent") && !$0.contains("Parent Alert") }
    XCTAssertTrue(parentTextLines.isEmpty, "Should not show standalone Parent text from content")
    XCTAssertFalse(output.contains("Show Alert"), "Should not show child button")
  }

  // MARK: - Edge Cases Tests

  func testAlertLongTitle() {
    // Given - Alert with long title
    var dismissed = false
    let alert = Alert(
      title: "This is a very long alert title that should expand the alert width",
      dismiss: { dismissed = true }
    )

    // When
    let output = renderAlert(alert)

    // Then
    XCTAssertTrue(output.contains("This is a very long alert title"), "Should show full long title")
    XCTAssertTrue(output.contains("[ OK ]"), "Should still show OK button")

    // Check that border expands to accommodate
    let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
    if let titleLine = lines.first(where: { $0.contains("This is a very long") }) {
      XCTAssertTrue(titleLine.contains("║"), "Should have proper borders even with long title")
    }
  }

  func testAlertLongMessage() {
    // Given - Alert with long message
    var dismissed = false
    let alert = Alert(
      title: "Notice",
      message: "This is a very long message that provides detailed information to the user",
      dismiss: { dismissed = true }
    )

    // When
    let output = renderAlert(alert)

    // Then
    XCTAssertTrue(output.contains("Notice"), "Should show title")
    XCTAssertTrue(output.contains("This is a very long message"), "Should show long message")
    XCTAssertTrue(output.contains("[ OK ]"), "Should show OK button")
  }

  func testAlertNoMessage() {
    // Given - Alert without message
    var dismissed = false
    let alert = Alert(title: "Simple", dismiss: { dismissed = true })

    // When
    let output = renderAlert(alert)
    let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }

    // Then
    XCTAssertTrue(output.contains("Simple"), "Should show title")
    XCTAssertTrue(output.contains("[ OK ]"), "Should show OK button")

    // Should be more compact without message
    XCTAssertLessThanOrEqual(lines.count, 7, "Should have compact layout without message")
  }

  func testAlertSpecialCharacters() {
    // Given - Alert with special characters and emoji
    var dismissed = false
    let alert = Alert(
      title: "⚠️ Warning!",
      message: "Special chars: <>&\"' and emoji 🎉",
      dismiss: { dismissed = true }
    )

    // When
    let output = renderAlert(alert)

    // Then
    XCTAssertTrue(output.contains("⚠️ Warning!"), "Should show emoji in title")
    XCTAssertTrue(output.contains("Special chars: <>&\"'"), "Should show special characters")
    XCTAssertTrue(output.contains("🎉"), "Should show emoji in message")
    XCTAssertTrue(output.contains("[ OK ]"), "Should show OK button")
  }
}
