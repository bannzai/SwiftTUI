//
//  EnvironmentTests.swift
//  SwiftTUITests
//
//  Tests for @Environment property wrapper and environment value propagation
//

import Testing
@testable import SwiftTUI
#if canImport(Observation)
import Observation
#endif

@Suite struct EnvironmentTests {
    
    // MARK: - Basic Environment Value Tests
    
    @Test func environmentForegroundColor() {
        // Given
        struct TestView: View {
            @Environment(\.foregroundColor) var textColor
            
            var body: some View {
                // デバッグ：実際の色の値を出力
                let colorName: String = {
                    if textColor == .red { return "Red" }
                    else if textColor == .green { return "Green" }
                    else if textColor == .white { return "White" }
                    else if textColor == .blue { return "Blue" }
                    else { return "Unknown(\(textColor))" }
                }()
                return Text("Color: \(colorName)")
            }
        }
        
        // When - default value
        let defaultOutput = TestRenderer.render(TestView(), width: 30, height: 5)
        
        // Then
        #expect(defaultOutput.contains("Color: White"), "Should show default color (white)")
        
        // When - with red color
        let redOutput = TestRenderer.render(
            TestView().environment(\.foregroundColor, .red),
            width: 30,
            height: 5
        )
        
        // Then
        #expect(redOutput.contains("Color: Red"), "Should show red color")
    }
    
    @Test func environmentIsEnabled() {
        // Given
        struct TestView: View {
            @Environment(\.isEnabled) var isEnabled
            
            var body: some View {
                Text("Enabled: \(isEnabled ? "Yes" : "No")")
            }
        }
        
        // When - default (enabled)
        let enabledOutput = TestRenderer.render(TestView(), width: 30, height: 5)
        
        // Then
        #expect(enabledOutput.contains("Enabled: Yes"), "Should be enabled by default")
        
        // When - disabled
        let disabledOutput = TestRenderer.render(
            TestView().disabled(),
            width: 30,
            height: 5
        )
        
        // Then
        #expect(disabledOutput.contains("Enabled: No"), "Should be disabled")
    }
    
    @Test func multipleEnvironmentValues() {
        // Given
        struct TestView: View {
            @Environment(\.foregroundColor) var color
            @Environment(\.isEnabled) var isEnabled
            @Environment(\.fontSize) var fontSize
            
            var body: some View {
                VStack {
                    Text("Color: \(color == .blue ? "Blue" : "Other")")
                    Text("Enabled: \(isEnabled)")
                    Text("Font: \(fontSize)")
                }
            }
        }
        
        // When - single environment modifier setting multiple values
        let customModifier = EnvironmentModifier(content: TestView()) { env in
            env.foregroundColor = .blue
            env.isEnabled = false
            env.fontSize = 20
        }
        let output = TestRenderer.render(customModifier, width: 30, height: 10)
        
        // Then
        #expect(output.contains("Color: Blue"), "Should have blue color")
        
        // Bool値の出力は "true" または "false" として文字列化される
        #expect(output.contains("Enabled: false") || output.contains("Enabled: 0"), 
                     "Should be disabled (output: \(output))")
        #expect(output.contains("Font: 20"), "Should have font size 20")
    }
    
    // MARK: - View Hierarchy Propagation Tests
    
    @Test func environmentPropagationToChild() {
        // Given
        struct ChildView: View {
            @Environment(\.foregroundColor) var color
            
            var body: some View {
                Text("Child: \(color == .yellow ? "Yellow" : "Other")")
            }
        }
        
        struct ParentView: View {
            var body: some View {
                VStack {
                    Text("Parent")
                    ChildView()
                }
            }
        }
        
        // When
        let output = TestRenderer.render(
            ParentView().environment(\.foregroundColor, .yellow),
            width: 30,
            height: 10
        )
        
        // Then
        #expect(output.contains("Parent"), "Should show parent text")
        #expect(output.contains("Child: Yellow"), "Child should inherit yellow color")
    }
    
    @Test func environmentOverrideInChild() {
        // Given
        struct ChildView: View {
            @Environment(\.foregroundColor) var color
            
            var body: some View {
                Text("Child: \(color == .green ? "Green" : color == .red ? "Red" : "Other")")
            }
        }
        
        struct ParentView: View {
            @Environment(\.foregroundColor) var parentColor
            
            var body: some View {
                VStack {
                    Text("Parent: \(parentColor == .red ? "Red" : "Other")")
                    ChildView()
                        .environment(\.foregroundColor, .green)
                }
            }
        }
        
        // When
        let output = TestRenderer.render(
            ParentView().environment(\.foregroundColor, .red),
            width: 40,
            height: 10
        )
        
        // Then
        #expect(output.contains("Parent: Red"), "Parent should have red color")
        #expect(output.contains("Child: Green"), "Child should override with green")
    }
    
    @Test func deepNestedEnvironmentPropagation() {
        // Given
        struct Level3View: View {
            @Environment(\.fontSize) var fontSize
            
            var body: some View {
                Text("Level3: \(fontSize)")
            }
        }
        
        struct Level2View: View {
            var body: some View {
                VStack {
                    Text("Level2")
                    Level3View()
                }
            }
        }
        
        struct Level1View: View {
            var body: some View {
                VStack {
                    Text("Level1")
                    Level2View()
                }
            }
        }
        
        // When
        let output = TestRenderer.render(
            Level1View().environment(\.fontSize, 24),
            width: 30,
            height: 10
        )
        
        // Then
        #expect(output.contains("Level1"), "Should show level 1")
        #expect(output.contains("Level2"), "Should show level 2")
        #expect(output.contains("Level3: 24"), "Level 3 should inherit font size")
    }
    
    // MARK: - SwiftTUI Observable Integration Tests
    
    @Test func swiftTUIObservableInEnvironment() {
        // Given
        class TestModel: Observable {
            var value = "Initial" {
                didSet { notifyChange() }
            }
        }
        
        struct TestView: View {
            @Environment(TestModel.self) var model: TestModel?
            
            var body: some View {
                if let model = model {
                    Text("Value: \(model.value)")
                } else {
                    Text("No model")
                }
            }
        }
        
        // When - no model
        let noModelOutput = TestRenderer.render(TestView(), width: 30, height: 5)
        
        // Then
        #expect(noModelOutput.contains("No model"), "Should show no model")
        
        // When - with model
        let model = TestModel()
        let withModelOutput = TestRenderer.render(
            TestView().environment(model),
            width: 30,
            height: 5
        )
        
        // Then
        #expect(withModelOutput.contains("Value: Initial"), "Should show model value")
    }
    
    @Test func multipleObservablesInEnvironment() {
        // Given
        class UserModel: Observable {
            var name = "John" {
                didSet { notifyChange() }
            }
        }
        
        class AppSettings: Observable {
            var theme = "Dark" {
                didSet { notifyChange() }
            }
        }
        
        struct TestView: View {
            @Environment(UserModel.self) var user: UserModel?
            @Environment(AppSettings.self) var settings: AppSettings?
            
            var body: some View {
                VStack {
                    Text("User: \(user?.name ?? "None")")
                    Text("Theme: \(settings?.theme ?? "None")")
                }
            }
        }
        
        // When - single environment modifier with multiple observables
        let user = UserModel()
        let settings = AppSettings()
        let customModifier = EnvironmentModifier(content: TestView()) { env in
            let userKey = ObjectIdentifier(UserModel.self)
            let settingsKey = ObjectIdentifier(AppSettings.self)
            env.observables[userKey] = user
            env.observables[settingsKey] = settings
        }
        let output = TestRenderer.render(customModifier, width: 30, height: 10)
        
        // Then
        #expect(output.contains("User: John"), "Should show user name")
        #expect(output.contains("Theme: Dark"), "Should show theme")
    }
    
    // MARK: - Standard Observable Integration Tests (Swift 5.9+)
    
    #if canImport(Observation)
    @Test func standardObservableInEnvironment() {
        // Given
        struct TestView: View {
            @Environment(TestStandardModel.self) var model: TestStandardModel?
            
            var body: some View {
                if let model = model {
                    Text("Message: \(model.message)")
                } else {
                    Text("No standard model")
                }
            }
        }
        
        // When
        let model = TestStandardModel()
        let output = TestRenderer.render(
            TestView().environment(model),
            width: 40,
            height: 5
        )
        
        // Then
        #expect(output.contains("Message: Hello Standard"), "Should show standard model message")
    }
    
    @Test func mixedObservableTypes() {
        // Given - SwiftTUI Observable
        class SwiftTUIModel: Observable {
            var value = "SwiftTUI" {
                didSet { notifyChange() }
            }
        }
        
        struct TestView: View {
            @Environment(SwiftTUIModel.self) var swiftTUIModel: SwiftTUIModel?
            @Environment(TestStandardValueModel.self) var standardModel: TestStandardValueModel?
            
            var body: some View {
                VStack {
                    Text("SwiftTUI: \(swiftTUIModel?.value ?? "None")")
                    Text("Standard: \(standardModel?.value ?? "None")")
                }
            }
        }
        
        // When - single environment modifier with both observable types
        let swiftTUIModel = SwiftTUIModel()
        let standardModel = TestStandardValueModel()
        let customModifier = EnvironmentModifier(content: TestView()) { env in
            // Set SwiftTUI Observable
            let swiftTUIKey = ObjectIdentifier(SwiftTUIModel.self)
            env.observables[swiftTUIKey] = swiftTUIModel
            
            // Set Standard Observable
            #if canImport(Observation)
            let standardKey = ObjectIdentifier(TestStandardValueModel.self)
            let box = AnyObservableBox(standardModel)
            env.observableBoxes[standardKey] = box
            #endif
        }
        let output = TestRenderer.render(customModifier, width: 40, height: 10)
        
        // Then
        #expect(output.contains("SwiftTUI: SwiftTUI"), "Should show SwiftTUI model")
        #expect(output.contains("Standard: Standard"), "Should show standard model")
    }
    #endif
    
    // MARK: - Custom Environment Value Tests
    
    @Test func customEnvironmentKey() {
        // Given - Custom environment key
        struct ThemeKey: EnvironmentKey {
            static let defaultValue = "Light"
        }
        
        // Extend EnvironmentValues in test
        struct TestEnvironment {
            static func theme(from env: EnvironmentValues) -> String {
                env[ThemeKey.self]
            }
            
            static func setTheme(_ theme: String, in env: inout EnvironmentValues) {
                env[ThemeKey.self] = theme
            }
        }
        
        struct TestView: View {
            var body: some View {
                // Since we can't add computed properties to EnvironmentValues in tests,
                // we'll access the value directly through our helper
                let theme = TestEnvironment.theme(from: EnvironmentValues.current)
                return Text("Theme: \(theme)")
            }
        }
        
        // When - default
        let defaultOutput = TestRenderer.render(TestView(), width: 30, height: 5)
        
        // Then
        #expect(defaultOutput.contains("Theme: Light"), "Should show default theme")
        
        // When - custom value
        let customView = EnvironmentModifier(content: TestView()) { env in
            TestEnvironment.setTheme("Dark", in: &env)
        }
        let customOutput = TestRenderer.render(customView, width: 30, height: 5)
        
        // Then
        #expect(customOutput.contains("Theme: Dark"), "Should show custom theme")
    }
    
    // MARK: - Edge Cases
    
    @Test func environmentChaining() {
        // Given
        struct TestView: View {
            @Environment(\.foregroundColor) var color
            @Environment(\.isEnabled) var isEnabled
            
            var body: some View {
                Text("Color: \(color == .green ? "Green" : "Other"), Enabled: \(isEnabled)")
            }
        }
        
        // When - single environment modifier with multiple values
        let customModifier = EnvironmentModifier(content: TestView()) { env in
            env.foregroundColor = .green
            env.isEnabled = false
            env.fontSize = 18
        }
        let output = TestRenderer.render(customModifier, width: 50, height: 5)
        
        // Then
        #expect(output.contains("Color: Green"), "Should have green color")
        #expect(output.contains("Enabled: false"), "Should be disabled")
    }
    
    @Test func disabledModifier() {
        // Given
        struct TestView: View {
            @Environment(\.isEnabled) var isEnabled
            
            var body: some View {
                VStack {
                    Text("Parent: \(isEnabled ? "Enabled" : "Disabled")")
                    ChildView()
                }
            }
        }
        
        struct ChildView: View {
            @Environment(\.isEnabled) var isEnabled
            
            var body: some View {
                Text("Child: \(isEnabled ? "Enabled" : "Disabled")")
            }
        }
        
        // When - using disabled()
        let output = TestRenderer.render(
            TestView().disabled(),
            width: 40,
            height: 10
        )
        
        // Then
        #expect(output.contains("Parent: Disabled"), "Parent should be disabled")
        #expect(output.contains("Child: Disabled"), "Child should inherit disabled state")
    }
    
    @Test func environmentWithConditionalView() {
        // Given
        struct TestView: View {
            @Environment(\.foregroundColor) var color
            let showAlternate: Bool
            
            var body: some View {
                if showAlternate {
                    Text("Alternate: \(color == .blue ? "Blue" : "Other")")
                } else {
                    Text("Primary: \(color == .blue ? "Blue" : "Other")")
                }
            }
        }
        
        // When - primary view
        let primaryOutput = TestRenderer.render(
            TestView(showAlternate: false).environment(\.foregroundColor, .blue),
            width: 30,
            height: 5
        )
        
        // Then
        #expect(primaryOutput.contains("Primary: Blue"), "Primary should have blue color")
        
        // When - alternate view
        let alternateOutput = TestRenderer.render(
            TestView(showAlternate: true).environment(\.foregroundColor, .blue),
            width: 30,
            height: 5
        )
        
        // Then
        #expect(alternateOutput.contains("Alternate: Blue"), "Alternate should have blue color")
    }
}

// MARK: - Standard Observable Test Classes (Swift 5.9+)

#if canImport(Observation)
// Standard Observable classes must be defined at file level due to macro restrictions
@Observable
class TestStandardModel {
    var message = "Hello Standard"
}

@Observable
class TestStandardValueModel {
    var value = "Standard"
}
#endif