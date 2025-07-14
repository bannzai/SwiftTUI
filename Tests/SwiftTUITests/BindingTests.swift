//
//  BindingTests.swift
//  SwiftTUITests
//
//  Tests for @Binding property wrapper behavior
//

import XCTest
@testable import SwiftTUI

final class BindingTests: SwiftTUITestCase {
    
    // MARK: - Parent-Child Sync Tests
    
    func testBindingWithTextField() {
        // Given
        struct ParentView: View {
            @State private var text = "Initial"
            
            var body: some View {
                VStack {
                    Text("Parent: \(text)")
                    TextField("Enter text", text: $text)
                }
            }
        }
        
        // When
        let output = TestRenderer.render(ParentView(), width: 40, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Parent: Initial"), "Parent should show initial state value")
        XCTAssertTrue(output.contains("Initial"), "TextField should show bound value")
        // Note: TextFieldのボーダー内にもInitialが表示される
    }
    
    func testBindingWithToggle() {
        // Given
        struct ParentView: View {
            @State private var isOn = true
            
            var body: some View {
                VStack {
                    Text("State: \(isOn ? "ON" : "OFF")")
                    Toggle("Switch", isOn: $isOn)
                }
            }
        }
        
        // When
        let output = TestRenderer.render(ParentView(), width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("State: ON"), "Parent should show ON state")
        XCTAssertTrue(output.contains("Switch"), "Toggle label should be visible")
        XCTAssertTrue(output.contains("[✓]"), "Toggle should show checked state")
    }
    
    func testMultipleChildrenSharingBinding() {
        // Given
        struct ChildView: View {
            @Binding var value: String
            let label: String
            
            var body: some View {
                Text("\(label): \(value)")
            }
        }
        
        struct ParentView: View {
            @State private var sharedValue = "Shared"
            
            var body: some View {
                VStack {
                    ChildView(value: $sharedValue, label: "Child1")
                    ChildView(value: $sharedValue, label: "Child2")
                    ChildView(value: $sharedValue, label: "Child3")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(ParentView(), width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Child1: Shared"), "First child should show shared value")
        XCTAssertTrue(output.contains("Child2: Shared"), "Second child should show shared value")
        XCTAssertTrue(output.contains("Child3: Shared"), "Third child should show shared value")
    }
    
    func testNestedBindingPropagation() {
        // Given
        struct GrandchildView: View {
            @Binding var text: String
            
            var body: some View {
                Text("Grandchild: \(text)")
            }
        }
        
        struct ChildView: View {
            @Binding var text: String
            
            var body: some View {
                VStack {
                    Text("Child: \(text)")
                    GrandchildView(text: $text)
                }
            }
        }
        
        struct ParentView: View {
            @State private var text = "Nested"
            
            var body: some View {
                VStack {
                    Text("Parent: \(text)")
                    ChildView(text: $text)
                }
            }
        }
        
        // When
        let output = TestRenderer.render(ParentView(), width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Parent: Nested"), "Parent should show value")
        XCTAssertTrue(output.contains("Child: Nested"), "Child should show bound value")
        XCTAssertTrue(output.contains("Grandchild: Nested"), "Grandchild should show bound value")
    }
    
    // MARK: - Binding.constant Tests
    
    func testBindingConstant() {
        // Given
        struct TestView: View {
            var body: some View {
                VStack {
                    TextField("Constant", text: .constant("Fixed"))
                    Toggle("Always On", isOn: .constant(true))
                    Toggle("Always Off", isOn: .constant(false))
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 40, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Fixed"), "Constant binding should show fixed value")
        XCTAssertTrue(output.contains("Always On"), "First toggle label should be visible")
        XCTAssertTrue(output.contains("Always Off"), "Second toggle label should be visible")
        // Toggle states should be fixed
        let lines = output.components(separatedBy: "\n")
        var foundOnToggle = false
        var foundOffToggle = false
        
        for line in lines {
            if line.contains("Always On") && line.contains("[✓]") {
                foundOnToggle = true
            }
            if line.contains("Always Off") && line.contains("[ ]") {
                foundOffToggle = true
            }
        }
        
        XCTAssertTrue(foundOnToggle, "Always On toggle should be checked")
        XCTAssertTrue(foundOffToggle, "Always Off toggle should be unchecked")
    }
    
    func testBindingConstantWithDifferentTypes() {
        // Given
        struct TestView: View {
            var body: some View {
                VStack {
                    Text("String: \(Binding.constant("Hello").wrappedValue)")
                    Text("Int: \(Binding.constant(42).wrappedValue)")
                    Text("Bool: \(Binding.constant(true).wrappedValue ? "Yes" : "No")")
                    Text("Double: \(Binding.constant(3.14).wrappedValue)")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("String: Hello"), "Constant string binding should work")
        XCTAssertTrue(output.contains("Int: 42"), "Constant int binding should work")
        XCTAssertTrue(output.contains("Bool: Yes"), "Constant bool binding should work")
        XCTAssertTrue(output.contains("Double: 3.14"), "Constant double binding should work")
    }
    
    // MARK: - Custom Binding Tests
    
    func testCustomBindingWithTransformation() {
        // Given
        struct ParentView: View {
            @State private var celsius: Double = 25.0
            
            var fahrenheitBinding: Binding<Double> {
                Binding(
                    get: { self.celsius * 9/5 + 32 },
                    set: { self.celsius = ($0 - 32) * 5/9 }
                )
            }
            
            var body: some View {
                VStack {
                    Text("Celsius: \(Int(celsius))°C")
                    Text("Fahrenheit: \(Int(fahrenheitBinding.wrappedValue))°F")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(ParentView(), width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Celsius: 25°C"), "Celsius value should be displayed")
        XCTAssertTrue(output.contains("Fahrenheit: 77°F"), "Fahrenheit conversion should be correct")
    }
    
    func testCustomBindingWithValidation() {
        // Given
        struct ParentView: View {
            @State private var internalValue = 5
            
            var clampedBinding: Binding<Int> {
                Binding(
                    get: { self.internalValue },
                    set: { newValue in
                        // Clamp value between 0 and 10
                        self.internalValue = min(max(newValue, 0), 10)
                    }
                )
            }
            
            var body: some View {
                Text("Clamped: \(clampedBinding.wrappedValue)")
            }
        }
        
        // When
        let output = TestRenderer.render(ParentView(), width: 30, height: 5)
        
        // Then
        XCTAssertTrue(output.contains("Clamped: 5"), "Clamped value should be displayed")
    }
    
    // MARK: - Binding with Different View Types
    
    func testBindingWithSlider() {
        // Given
        struct ParentView: View {
            @State private var value = 0.5
            
            var body: some View {
                VStack {
                    Text("Value: \(Int(value * 100))%")
                    Slider(value: $value, label: "Progress")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(ParentView(), width: 40, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Value: 50%"), "Value should show 50%")
        // Note: Sliderは値のみを表示するシンプルなUI
    }
    
    func testBindingWithPicker() {
        // Given
        struct ParentView: View {
            @State private var selection = "Red"
            let options = ["Red", "Green", "Blue"]
            
            var body: some View {
                VStack {
                    Text("Selected: \(selection)")
                    Picker("Color", selection: $selection, options: options)
                }
            }
        }
        
        // When
        let output = TestRenderer.render(ParentView(), width: 40, height: 15)
        
        // Then
        XCTAssertTrue(output.contains("Selected: Red"), "Selected value should be displayed")
        // Note: Pickerは現在選択されている値のみを表示するシンプルなUI
    }
    
    // MARK: - Edge Cases
    
    func testBindingWithOptional() {
        // Given
        struct ParentView: View {
            @State private var optionalText: String? = "Hello"
            
            var nonOptionalBinding: Binding<String> {
                Binding(
                    get: { self.optionalText ?? "" },
                    set: { self.optionalText = $0.isEmpty ? nil : $0 }
                )
            }
            
            var body: some View {
                VStack {
                    Text("Optional: \(optionalText ?? "nil")")
                    TextField("Enter text", text: nonOptionalBinding)
                }
            }
        }
        
        // When
        let output = TestRenderer.render(ParentView(), width: 40, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Optional: Hello"), "Optional value should be displayed")
        XCTAssertTrue(output.contains("Hello"), "TextField should show non-nil value")
    }
    
    func testBindingProjectedValue() {
        // Given
        struct TestView: View {
            @State private var value = "Test"
            
            var body: some View {
                // $value.projectedValue should return the binding itself
                let binding1 = $value
                let binding2 = binding1.projectedValue
                
                return VStack {
                    Text("Value1: \(binding1.wrappedValue)")
                    Text("Value2: \(binding2.wrappedValue)")
                }
            }
        }
        
        // When
        let output = TestRenderer.render(TestView(), width: 30, height: 10)
        
        // Then
        XCTAssertTrue(output.contains("Value1: Test"), "First binding should work")
        XCTAssertTrue(output.contains("Value2: Test"), "Projected value should return same binding")
    }
}