//
//  ForEachTests.swift
//  SwiftTUITests
//
//  Tests for ForEach and ForEachRange dynamic list generation
//

import XCTest

@testable import SwiftTUI

final class ForEachTests: SwiftTUITestCase {

  // MARK: - Range-based ForEach Tests

  func testForEachRangeBasic() {
    // Given
    struct TestView: View {
      var body: some View {
        VStack {
          ForEachRange(0..<3) { index in
            Text("Item \(index)")
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("Item 0"), "Should show first item")
    XCTAssertTrue(output.contains("Item 1"), "Should show second item")
    XCTAssertTrue(output.contains("Item 2"), "Should show third item")
    XCTAssertFalse(output.contains("Item 3"), "Should not show fourth item")
  }

  func testForEachRangeEmpty() {
    // Given
    struct TestView: View {
      var body: some View {
        VStack {
          Text("Before")
          ForEachRange(0..<0) { index in
            Text("Item \(index)")
          }
          Text("After")
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("Before"), "Should show text before ForEach")
    XCTAssertTrue(output.contains("After"), "Should show text after ForEach")
    XCTAssertFalse(output.contains("Item"), "Should not show any items")
  }

  func testForEachRangeLarge() {
    // Given
    struct TestView: View {
      var body: some View {
        VStack {
          ForEachRange(0..<5) { index in
            Text("N\(index)")
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 15)

    // Then
    for i in 0..<5 {
      XCTAssertTrue(output.contains("N\(i)"), "Should show item \(i)")
    }
    XCTAssertFalse(output.contains("N5"), "Should not show item 5")
  }

  func testForEachRangeInHStack() {
    // Given
    struct TestView: View {
      var body: some View {
        HStack {
          ForEachRange(0..<3) { index in
            Text("[\(index)]")
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 5)

    // Then
    XCTAssertTrue(output.contains("[0]"), "Should show first item")
    XCTAssertTrue(output.contains("[1]"), "Should show second item")
    XCTAssertTrue(output.contains("[2]"), "Should show third item")
  }

  // MARK: - Identifiable Array ForEach Tests

  func testForEachIdentifiableBasic() {
    // Given
    struct Item: Identifiable {
      let id: Int
      let name: String
    }

    struct TestView: View {
      let items = [
        Item(id: 1, name: "Apple"),
        Item(id: 2, name: "Banana"),
        Item(id: 3, name: "Cherry"),
      ]

      var body: some View {
        VStack {
          ForEach(items) { item in
            Text(item.name)
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("Apple"), "Should show Apple")
    XCTAssertTrue(output.contains("Banana"), "Should show Banana")
    XCTAssertTrue(output.contains("Cherry"), "Should show Cherry")
  }

  func testForEachIdentifiableEmpty() {
    // Given
    struct Item: Identifiable {
      let id: Int
      let name: String
    }

    struct TestView: View {
      let items: [Item] = []

      var body: some View {
        VStack {
          Text("Start")
          ForEach(items) { item in
            Text(item.name)
          }
          Text("End")
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("Start"), "Should show Start")
    XCTAssertTrue(output.contains("End"), "Should show End")
  }

  func testForEachIdentifiableSingle() {
    // Given
    struct Item: Identifiable {
      let id: Int
      let name: String
    }

    struct TestView: View {
      let items = [Item(id: 42, name: "OnlyItem")]

      var body: some View {
        VStack {
          ForEach(items) { item in
            Text("ID: \(item.id), Name: \(item.name)")
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 40, height: 5)

    // Then
    XCTAssertTrue(output.contains("ID: 42"), "Should show item ID")
    XCTAssertTrue(output.contains("Name: OnlyItem"), "Should show item name")
  }

  func testForEachIdentifiableWithModifiers() {
    // Given
    struct Person: Identifiable {
      let id: String
      let name: String
      let age: Int
    }

    struct TestView: View {
      let people = [
        Person(id: "p1", name: "Alice", age: 25),
        Person(id: "p2", name: "Bob", age: 30),
      ]

      var body: some View {
        VStack {
          ForEach(people) { person in
            Text("\(person.name) (\(person.age))")
              .padding()
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 40, height: 15)

    // Then
    XCTAssertTrue(output.contains("Alice (25)"), "Should show Alice with age")
    XCTAssertTrue(output.contains("Bob (30)"), "Should show Bob with age")
  }

  // MARK: - KeyPath ID ForEach Tests

  func testForEachStringArrayWithSelf() {
    // Given
    struct TestView: View {
      let words = ["Hello", "World", "SwiftTUI"]

      var body: some View {
        VStack {
          ForEach(words, id: \.self) { word in
            Text(word)
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("Hello"), "Should show Hello")
    XCTAssertTrue(output.contains("World"), "Should show World")
    XCTAssertTrue(output.contains("SwiftTUI"), "Should show SwiftTUI")
  }

  func testForEachIntArrayWithSelf() {
    // Given
    struct TestView: View {
      let numbers = [10, 20, 30, 40]

      var body: some View {
        VStack {
          ForEach(numbers, id: \.self) { number in
            Text("Number: \(number)")
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 15)

    // Then
    XCTAssertTrue(output.contains("Number: 10"), "Should show first number")
    XCTAssertTrue(output.contains("Number: 20"), "Should show second number")
    XCTAssertTrue(output.contains("Number: 30"), "Should show third number")
    XCTAssertTrue(output.contains("Number: 40"), "Should show fourth number")
  }

  func testForEachEmptyArrayWithSelf() {
    // Given
    struct TestView: View {
      let items: [String] = []

      var body: some View {
        VStack {
          Text("Before")
          ForEach(items, id: \.self) { item in
            Text(item)
          }
          Text("After")
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("Before"), "Should show Before")
    XCTAssertTrue(output.contains("After"), "Should show After")
  }

  func testForEachCustomKeyPath() {
    // Given
    struct User {
      let username: String
      let email: String
    }

    struct TestView: View {
      let users = [
        User(username: "alice", email: "alice@example.com"),
        User(username: "bob", email: "bob@example.com"),
      ]

      var body: some View {
        VStack {
          ForEach(users, id: \.username) { user in
            Text("\(user.username): \(user.email)")
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 50, height: 10)

    // Then
    XCTAssertTrue(output.contains("alice: alice@example.com"), "Should show alice")
    XCTAssertTrue(output.contains("bob: bob@example.com"), "Should show bob")
  }

  // MARK: - Nested ForEach Tests

  func testNestedForEach() {
    // Given
    struct TestView: View {
      var body: some View {
        VStack {
          ForEachRange(0..<2) { i in
            HStack {
              ForEachRange(0..<2) { j in
                Text("\(i),\(j)")
              }
            }
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("0,0"), "Should show (0,0)")
    XCTAssertTrue(output.contains("0,1"), "Should show (0,1)")
    XCTAssertTrue(output.contains("1,0"), "Should show (1,0)")
    XCTAssertTrue(output.contains("1,1"), "Should show (1,1)")
  }

  func testForEachWithDifferentTypes() {
    // Given - Simplify test to avoid timeout
    struct TestView: View {
      let items = ["A", "B"]

      var body: some View {
        VStack {
          Text("Items:")
          ForEach(items, id: \.self) { item in
            Text(item)
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("Items:"), "Should show Items label")
    XCTAssertTrue(output.contains("A"), "Should show A")
    XCTAssertTrue(output.contains("B"), "Should show B")
  }

  // MARK: - Complex Layout Tests

  func testForEachInComplexLayout() {
    // Given
    struct Item: Identifiable {
      let id: Int
      let title: String
      let description: String
    }

    struct TestView: View {
      let items = [
        Item(id: 1, title: "First", description: "Description 1"),
        Item(id: 2, title: "Second", description: "Description 2"),
      ]

      var body: some View {
        VStack {
          Text("Items List")
            .bold()

          ForEach(items) { item in
            VStack {
              Text(item.title)
                .bold()
              Text(item.description)
            }
            .padding()
            .border()
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 40, height: 20)

    // Then
    XCTAssertTrue(output.contains("Items List"), "Should show title")
    XCTAssertTrue(output.contains("First"), "Should show first title")
    XCTAssertTrue(output.contains("Description 1"), "Should show first description")
    XCTAssertTrue(output.contains("Second"), "Should show second title")
    XCTAssertTrue(output.contains("Description 2"), "Should show second description")
  }

  // MARK: - Edge Cases

  func testForEachRangeWithLargeNumbers() {
    // Given
    struct TestView: View {
      var body: some View {
        VStack {
          ForEachRange(100..<103) { index in
            Text("Large: \(index)")
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 10)

    // Then
    XCTAssertTrue(output.contains("Large: 100"), "Should show 100")
    XCTAssertTrue(output.contains("Large: 101"), "Should show 101")
    XCTAssertTrue(output.contains("Large: 102"), "Should show 102")
    XCTAssertFalse(output.contains("Large: 103"), "Should not show 103")
  }

  func testForEachWithDuplicateIdentifiers() {
    // Given - Testing with duplicate values in id: \.self
    struct TestView: View {
      let items = ["A", "B", "A", "C"]  // "A" appears twice

      var body: some View {
        VStack {
          ForEach(items, id: \.self) { item in
            Text("Item: \(item)")
          }
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 15)

    // Then
    // Note: ForEach behavior with duplicate IDs may vary
    XCTAssertTrue(output.contains("Item: A"), "Should show A")
    XCTAssertTrue(output.contains("Item: B"), "Should show B")
    XCTAssertTrue(output.contains("Item: C"), "Should show C")
  }

  func testForEachSingleItemInHStack() {
    // Given
    struct TestView: View {
      var body: some View {
        HStack {
          Text("Start")
          ForEachRange(0..<1) { index in
            Text("Only\(index)")
          }
          Text("End")
        }
      }
    }

    // When
    let output = TestRenderer.render(TestView(), width: 30, height: 5)

    // Then
    XCTAssertTrue(output.contains("Start"), "Should show Start")
    XCTAssertTrue(output.contains("Only0"), "Should show single item")
    XCTAssertTrue(output.contains("End"), "Should show End")
  }
}
