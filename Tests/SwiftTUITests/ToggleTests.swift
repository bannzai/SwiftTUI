//
//  ToggleTests.swift
//  SwiftTUITests
//
//  Tests for Toggle component with on/off state and binding functionality
//

import XCTest

@testable import SwiftTUI

final class ToggleTests: SwiftTUITestCase {

  // MARK: - Basic Display Tests

  func testToggleBasicOff() {
    // Given - Toggle in OFF state
    struct TestView: View {
      @State private var isOn = false

      var body: some View {
        Toggle("Option", isOn: $isOn)
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 20, height: 5)

    // Then - Should show unchecked box with label
    XCTAssertTrue(output.contains("[ ]"), "Should show unchecked checkbox")
    XCTAssertTrue(output.contains("Option"), "Should show label")
    XCTAssertFalse(output.contains("[✓]"), "Should not show checked checkbox")
  }

  func testToggleBasicOn() {
    // Given - Toggle in ON state
    struct TestView: View {
      @State private var isOn = true

      var body: some View {
        Toggle("Enabled", isOn: $isOn)
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 20, height: 5)

    // Then - Should show checked box with label
    XCTAssertTrue(output.contains("[✓]"), "Should show checked checkbox")
    XCTAssertTrue(output.contains("Enabled"), "Should show label")
    XCTAssertFalse(output.contains("[ ]"), "Should not show unchecked checkbox")
  }

  func testToggleWithLabel() {
    // Given - Toggle with different labels
    struct TestView: View {
      @State private var option1 = false
      @State private var option2 = true

      var body: some View {
        VStack {
          Toggle("Enable Feature", isOn: $option1)
          Toggle("Dark Mode", isOn: $option2)
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("[ ]"), "Should show unchecked for option1")
    XCTAssertTrue(output.contains("Enable Feature"), "Should show first label")
    XCTAssertTrue(output.contains("[✓]"), "Should show checked for option2")
    XCTAssertTrue(output.contains("Dark Mode"), "Should show second label")
  }

  func testToggleMultiple() {
    // Given - Multiple toggles with independent states
    struct TestView: View {
      @State private var notifications = true
      @State private var sounds = false
      @State private var vibration = true

      var body: some View {
        VStack {
          Toggle("Notifications", isOn: $notifications)
          Toggle("Sounds", isOn: $sounds)
          Toggle("Vibration", isOn: $vibration)
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then - Each toggle should show correct state
    XCTAssertTrue(output.contains("Notifications"), "Should show Notifications label")
    XCTAssertTrue(output.contains("Sounds"), "Should show Sounds label")
    XCTAssertTrue(output.contains("Vibration"), "Should show Vibration label")
    // Count occurrences of checked/unchecked
    let checkedCount = output.components(separatedBy: "[✓]").count - 1
    let uncheckedCount = output.components(separatedBy: "[ ]").count - 1
    XCTAssertEqual(checkedCount, 2, "Should have 2 checked toggles")
    XCTAssertEqual(uncheckedCount, 1, "Should have 1 unchecked toggle")
  }

  // MARK: - Binding State Management Tests

  func testToggleBinding() {
    // Given - Toggle with binding to parent state
    struct ChildView: View {
      @Binding var isEnabled: Bool

      var body: some View {
        Toggle("Child Toggle", isOn: $isEnabled)
      }
    }

    struct ParentView: View {
      @State private var parentState = true

      var body: some View {
        VStack {
          Text(parentState ? "ON" : "OFF")
          ChildView(isEnabled: $parentState)
        }
      }
    }

    // When
    let output = TestRenderer.render(ParentView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("ON"), "Should show ON state in parent")
    XCTAssertTrue(output.contains("[✓]"), "Should show checked toggle")
    XCTAssertTrue(output.contains("Child Toggle"), "Should show child label")
  }

  func testToggleInitialValue() {
    // Given - Toggles with different initial values
    struct TestView: View {
      @State private var defaultFalse = false
      @State private var defaultTrue = true

      var body: some View {
        VStack {
          Toggle("Default False", isOn: $defaultFalse)
          Toggle("Default True", isOn: $defaultTrue)
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(
      output.contains("[ ]") && output.contains("Default False"),
      "Should show unchecked for default false")
    XCTAssertTrue(
      output.contains("[✓]") && output.contains("Default True"),
      "Should show checked for default true")
  }

  func testToggleMultipleBindings() {
    // Given - Multiple independent bindings
    struct SettingsView: View {
      @Binding var autoSave: Bool
      @Binding var autoBackup: Bool

      var body: some View {
        VStack {
          Toggle("Auto-save", isOn: $autoSave)
          Toggle("Auto-backup", isOn: $autoBackup)
        }
      }
    }

    struct TestView: View {
      @State private var save = true
      @State private var backup = false

      var body: some View {
        SettingsView(autoSave: $save, autoBackup: $backup)
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("Auto-save"), "Should show auto-save label")
    XCTAssertTrue(output.contains("Auto-backup"), "Should show auto-backup label")
    let lines = output.components(separatedBy: "\n")
    // Find lines containing toggles
    let autoSaveLine = lines.first { $0.contains("Auto-save") } ?? ""
    let autoBackupLine = lines.first { $0.contains("Auto-backup") } ?? ""
    XCTAssertTrue(autoSaveLine.contains("[✓]"), "Auto-save should be checked")
    XCTAssertTrue(autoBackupLine.contains("[ ]"), "Auto-backup should be unchecked")
  }

  func testToggleMixedStates() {
    // Given - Mix of ON and OFF states
    struct TestView: View {
      @State private var option0 = true
      @State private var option1 = false
      @State private var option2 = true
      @State private var option3 = false
      @State private var option4 = true

      var body: some View {
        VStack {
          Toggle("Option 0", isOn: $option0)
          Toggle("Option 1", isOn: $option1)
          Toggle("Option 2", isOn: $option2)
          Toggle("Option 3", isOn: $option3)
          Toggle("Option 4", isOn: $option4)
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 15)

    // Then
    XCTAssertTrue(output.contains("Option 0"), "Should show Option 0")
    XCTAssertTrue(output.contains("Option 1"), "Should show Option 1")
    XCTAssertTrue(output.contains("Option 2"), "Should show Option 2")
    XCTAssertTrue(output.contains("Option 3"), "Should show Option 3")
    XCTAssertTrue(output.contains("Option 4"), "Should show Option 4")
    // Should have 3 checked and 2 unchecked
    let checkedCount = output.components(separatedBy: "[✓]").count - 1
    let uncheckedCount = output.components(separatedBy: "[ ]").count - 1
    XCTAssertEqual(checkedCount, 3, "Should have 3 checked toggles")
    XCTAssertEqual(uncheckedCount, 2, "Should have 2 unchecked toggles")
  }

  // MARK: - Focus Management Tests

  func testToggleFocusDisplay() {
    // Given - Toggle that can be focused
    struct TestView: View {
      @State private var isOn = false

      var body: some View {
        Toggle("Focusable", isOn: $isOn)
        // In real usage, focus would be managed by FocusManager
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then - Basic display (focus state not testable in static test)
    XCTAssertTrue(output.contains("[ ]"), "Should show unchecked")
    XCTAssertTrue(output.contains("Focusable"), "Should show label")
  }

  func testToggleFocusSize() {
    // Given - Toggle size calculation
    struct TestView: View {
      @State private var isOn = false

      var body: some View {
        VStack {
          Text("Before")
          Toggle("Test", isOn: $isOn)
          Text("After")
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("Before"), "Should show text before")
    XCTAssertTrue(output.contains("[ ]"), "Should show toggle")
    XCTAssertTrue(output.contains("Test"), "Should show label")
    XCTAssertTrue(output.contains("After"), "Should show text after")
  }

  func testToggleMultipleFocus() {
    // Given - Multiple toggles (only one can be focused at a time)
    struct TestView: View {
      @State private var opt1 = false
      @State private var opt2 = true
      @State private var opt3 = false

      var body: some View {
        VStack {
          Toggle("First", isOn: $opt1)
          Toggle("Second", isOn: $opt2)
          Toggle("Third", isOn: $opt3)
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 15)

    // Then - All toggles should render correctly
    XCTAssertTrue(output.contains("First"), "Should show First")
    XCTAssertTrue(output.contains("Second"), "Should show Second")
    XCTAssertTrue(output.contains("Third"), "Should show Third")
  }

  // MARK: - Edge Cases Tests

  func testToggleEmptyLabel() {
    // Given - Toggle with empty label
    struct TestView: View {
      @State private var isOn = true

      var body: some View {
        Toggle("", isOn: $isOn)
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 20, height: 5)

    // Then - Should show checkbox only
    XCTAssertTrue(output.contains("[✓]"), "Should show checked checkbox")
  }

  func testToggleLongLabel() {
    // Given - Toggle with long label
    struct TestView: View {
      @State private var isOn = false

      var body: some View {
        Toggle("This is a very long label that might wrap or extend beyond the view", isOn: $isOn)
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 50, height: 5)

    // Then
    XCTAssertTrue(output.contains("[ ]"), "Should show unchecked checkbox")
    XCTAssertTrue(output.contains("very long label"), "Should show part of long label")
  }

  func testToggleSpecialCharacters() {
    // Given - Toggle with special characters and emoji
    struct TestView: View {
      @State private var emoji = true
      @State private var special = false

      var body: some View {
        VStack {
          Toggle("🎉 Party Mode", isOn: $emoji)
          Toggle("Option (1) & [2]", isOn: $special)
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("[✓]"), "Should show checked for emoji")
    XCTAssertTrue(output.contains("Party Mode"), "Should show party mode text")
    XCTAssertTrue(output.contains("[ ]"), "Should show unchecked for special")
    XCTAssertTrue(output.contains("Option (1) & [2]"), "Should show special characters")
  }

  func testToggleInVStack() {
    // Given - Toggles in VStack with other components
    struct TestView: View {
      @State private var setting1 = true
      @State private var setting2 = false

      var body: some View {
        VStack {
          Text("Settings")
            .bold()

          Toggle("Enable Feature A", isOn: $setting1)
          Toggle("Enable Feature B", isOn: $setting2)

          Spacer()

          Text("Status: \(setting1 ? "A" : "")\(setting2 ? "B" : "")")
        }
        .padding()
        .border()
      }
    }

    // When - Use larger height to ensure content fits
    let output = TestRenderer.render(TestView(), width: 40, height: 20)

    // Then
    XCTAssertTrue(output.contains("Settings"), "Should show title")
    XCTAssertTrue(output.contains("Enable Feature A"), "Should show feature A")
    XCTAssertTrue(output.contains("Enable Feature B"), "Should show feature B")
    XCTAssertTrue(output.contains("Status: A"), "Should show status with A enabled")
  }
}
