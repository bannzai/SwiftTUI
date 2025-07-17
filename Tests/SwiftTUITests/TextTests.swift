import XCTest

@testable import SwiftTUI

final class TextTests: SwiftTUITestCase {

  func testTextBasic() {
    // Given
    let text = Text("Hello, World")

    // When
    let output = TestRenderer.render(text)

    // Then
    assertRenderedOutput(text, equals: "Hello, World")
  }

  func testTextWithExclamation() {
    // Given
    let text = Text("Hello, World!")

    // When
    let output = TestRenderer.render(text)

    // Then
    assertRenderedOutput(text, equals: "Hello, World!")
  }

  func testTextWithStringInterpolation() {
    // Given
    let name = "SwiftTUI"
    let text = Text("Welcome to \(name)!")

    // When
    let output = TestRenderer.render(text)

    // Then
    assertRenderedOutput(text, equals: "Welcome to SwiftTUI!")
  }

  func testTextEmpty() {
    // Given
    let text = Text("")

    // When
    let output = TestRenderer.render(text)

    // Then
    assertRenderedOutput(text, equals: "")
  }

  func testTextWithSpecialCharacters() {
    // Given
    let text = Text("Hello @#$%^&*()!")

    // When
    let output = TestRenderer.render(text)

    // Then
    assertRenderedOutput(text, equals: "Hello @#$%^&*()!")
  }

  func testTextWithUnicode() {
    // Given
    let text = Text("こんにちは 👋")

    // When
    let output = TestRenderer.render(text)

    // Then
    assertRenderedOutput(text, equals: "こんにちは 👋")
  }

  func testTextWithNewlines() {
    // Given
    let text = Text("Line 1\nLine 2")

    // When
    let output = TestRenderer.render(text)

    // Then
    // Note: Text viewは改行を含む場合、1行として表示される
    assertRenderedOutput(text, equals: "Line 1\nLine 2")
  }
}
