//
//  StateTests.swift
//  SwiftTUITests
//
//  Tests for @State property wrapper behavior
//

import Testing
@testable import SwiftTUI

@Suite struct StateTests {
    
    // MARK: - Initial Value Tests
    
    @Test func stateWithStringInitialValue() {
        // Given
        struct TestView: View {
            @State private var text = "Hello"
            
            var body: some View {
                Text("Value: \(text)")
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 5)
        
        // Then
        #expect(output.contains("Value: Hello"), "Initial string value should be displayed")
    }
    
    @Test func stateWithIntegerInitialValue() {
        // Given
        struct TestView: View {
            @State private var count = 42
            
            var body: some View {
                Text("Count: \(count)")
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 5)
        
        // Then
        #expect(output.contains("Count: 42"), "Initial integer value should be displayed")
    }
    
    @Test func stateWithBoolInitialValue() {
        // Given
        struct TestView: View {
            @State private var isEnabled = true
            
            var body: some View {
                Text("Enabled: \(isEnabled ? "Yes" : "No")")
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 5)
        
        // Then
        #expect(output.contains("Enabled: Yes"), "Initial boolean value should be displayed")
    }
    
    @Test func stateWithCustomTypeInitialValue() {
        // Given
        struct User {
            let name: String
            let age: Int
        }
        
        struct TestView: View {
            @State private var user = User(name: "John", age: 30)
            
            var body: some View {
                VStack {
                    Text("Name: \(user.name)")
                    Text("Age: \(user.age)")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 10)
        
        // Then
        #expect(output.contains("Name: John"), "Custom type name should be displayed")
        #expect(output.contains("Age: 30"), "Custom type age should be displayed")
    }
    
    // MARK: - Multiple @State Properties Tests
    
    @Test func multipleStateProperties() {
        // Given
        struct TestView: View {
            @State private var firstName = "Jane"
            @State private var lastName = "Doe"
            @State private var age = 25
            
            var body: some View {
                VStack {
                    Text("First: \(firstName)")
                    Text("Last: \(lastName)")
                    Text("Age: \(age)")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 10)
        
        // Then
        #expect(output.contains("First: Jane"), "First state property should be displayed")
        #expect(output.contains("Last: Doe"), "Last state property should be displayed")
        #expect(output.contains("Age: 25"), "Age state property should be displayed")
        
        // Verify ordering
        let lines = output.components(separatedBy: "\n")
        var firstIndex = -1
        var lastIndex = -1
        var ageIndex = -1
        
        for (index, line) in lines.enumerated() {
            if line.contains("First: Jane") {
                firstIndex = index
            }
            if line.contains("Last: Doe") {
                lastIndex = index
            }
            if line.contains("Age: 25") {
                ageIndex = index
            }
        }
        
        if firstIndex != -1 && lastIndex != -1 && ageIndex != -1 {
            #expect(firstIndex < lastIndex, "First should appear before Last")
            #expect(lastIndex < ageIndex, "Last should appear before Age")
        }
    }
    
    @Test func mixedTypeStateProperties() {
        // Given
        struct TestView: View {
            @State private var title = "Dashboard"
            @State private var count = 0
            @State private var isActive = false
            @State private var progress = 0.5
            
            var body: some View {
                VStack {
                    Text(title)
                    Text("Items: \(count)")
                    Text("Active: \(isActive)")
                    Text("Progress: \(Int(progress * 100))%")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 10)
        
        // Then
        #expect(output.contains("Dashboard"), "String state should be displayed")
        #expect(output.contains("Items: 0"), "Int state should be displayed")
        #expect(output.contains("Active: false"), "Bool state should be displayed")
        #expect(output.contains("Progress: 50%"), "Double state should be displayed")
    }
    
    // MARK: - Nested View Independence Tests
    
    @Test func nestedViewStateIndependence() {
        // Given
        struct ChildView: View {
            @State private var childValue = "Child"
            
            var body: some View {
                Text("Child: \(childValue)")
            }
        }
        
        struct ParentView: View {
            @State private var parentValue = "Parent"
            
            var body: some View {
                VStack {
                    Text("Parent: \(parentValue)")
                    ChildView()
                }
            }
        }
        
        // When
        let output = TestRenderer.render(ParentView(), width: 30, height: 10)
        
        // Then
        #expect(output.contains("Parent: Parent"), "Parent state should be displayed")
        #expect(output.contains("Child: Child"), "Child state should be displayed")
    }
    
    @Test func multipleInstancesOfSameView() {
        // Given
        struct CounterView: View {
            @State private var count = 0
            let label: String
            
            var body: some View {
                Text("\(label): \(count)")
            }
        }
        
        struct ContainerView: View {
            var body: some View {
                VStack {
                    CounterView(label: "First")
                    CounterView(label: "Second")
                    CounterView(label: "Third")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(ContainerView(), width: 30, height: 10)
        
        // Then
        // Each instance should have its own independent state
        #expect(output.contains("First: 0"), "First counter should show 0")
        #expect(output.contains("Second: 0"), "Second counter should show 0")
        #expect(output.contains("Third: 0"), "Third counter should show 0")
    }
    
    // MARK: - Binding Tests
    
    @Test func stateProjectedValueBinding() {
        // Given
        struct ChildView: View {
            @Binding var text: String
            
            var body: some View {
                Text("Bound: \(text)")
            }
        }
        
        struct ParentView: View {
            @State private var text = "Hello Binding"
            
            var body: some View {
                VStack {
                    Text("State: \(text)")
                    ChildView(text: $text)
                }
            }
        }
        
        // When
        let output = TestRenderer.render(ParentView(), width: 40, height: 10)
        
        // Then
        #expect(output.contains("State: Hello Binding"), "State value should be displayed")
        #expect(output.contains("Bound: Hello Binding"), "Bound value should match state")
    }
    
    // MARK: - Edge Cases
    
    @Test func stateWithEmptyString() {
        // Given
        struct TestView: View {
            @State private var empty = ""
            
            var body: some View {
                VStack {
                    Text("Empty: '\(empty)'")
                    Text("Length: \(empty.count)")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 10)
        
        // Then
        #expect(output.contains("Empty: ''"), "Empty string should be displayed")
        #expect(output.contains("Length: 0"), "Empty string length should be 0")
    }
    
    @Test func stateWithOptionalValue() {
        // Given
        struct TestView: View {
            @State private var optionalText: String? = nil
            @State private var optionalNumber: Int? = 42
            
            var body: some View {
                VStack {
                    Text("Text: \(optionalText ?? "nil")")
                    Text("Number: \(optionalNumber.map { String($0) } ?? "nil")")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 10)
        
        // Then
        #expect(output.contains("Text: nil"), "Nil optional should show 'nil'")
        #expect(output.contains("Number: 42"), "Non-nil optional should show value")
    }
    
    @Test func stateWithArray() {
        // Given
        struct TestView: View {
            @State private var items = ["Apple", "Banana", "Cherry"]
            
            var body: some View {
                VStack {
                    Text("Count: \(items.count)")
                    ForEach(0..<items.count, id: \.self) { index in
                        Text("- \(items[index])")
                    }
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 10)
        
        // Then
        #expect(output.contains("Count: 3"), "Array count should be displayed")
        #expect(output.contains("- Apple"), "First item should be displayed")
        #expect(output.contains("- Banana"), "Second item should be displayed")
        #expect(output.contains("- Cherry"), "Third item should be displayed")
    }
}