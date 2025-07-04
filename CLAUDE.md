# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Vision

SwiftTUI is the Swift equivalent of React's Ink - a Terminal User Interface (TUI) library that brings SwiftUI's declarative paradigm to terminal applications. Just as Ink enables React developers to build TUIs with familiar React patterns, SwiftTUI allows Swift developers to create terminal interfaces using SwiftUI-like syntax.

## Core Philosophy

### 1. SwiftUI-Compatible API
- **MUST** follow SwiftUI's API patterns exactly
- Views are structs conforming to `View` protocol
- All views implement `var body: some View` computed property
- ViewModifiers are applied via method chaining (`.padding()`, `.border()`, etc.)
- **NO** manual render calls - the framework handles all rendering internally

### 2. Declarative, Not Imperative
- Users describe WHAT the UI should look like, not HOW to render it
- State changes automatically trigger re-renders
- No manual buffer manipulation or coordinate calculations in user code

### 3. Familiar to SwiftUI Developers
- A SwiftUI developer should be able to use SwiftTUI with minimal learning curve
- Same mental model: Views, Modifiers, State management
- Same patterns: `@State`, `@Binding`, `@ObservedObject` (when implemented)

## Development Guidelines

### API Design Principles

```swift
// ✅ GOOD - SwiftUI-like
struct ContentView: View {
    @State private var name = ""
    
    var body: some View {
        VStack {
            Text("Hello, \(name)!")
                .foregroundColor(.green)
                .bold()
            
            TextField("Enter name", text: $name)
                .border()
                .padding()
        }
    }
}

// ❌ BAD - Current implementation (to be refactored)
struct ContentView: LayoutView {
    func makeNode() -> YogaNode { ... }
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) { ... }
    func render(into buffer: inout [String]) { ... }
}
```

### Implementation Strategy

1. **View Protocol Evolution**
   - Transition from current `LayoutView` with `render(into:)` to SwiftUI-style `View` with `body`
   - Hide Yoga implementation details completely
   - Automatic layout calculation based on view hierarchy

2. **ViewModifier Protocol**
   - Implement proper ViewModifier protocol
   - Enable method chaining for all modifiers
   - Modifiers return `some View`, not concrete types

3. **Rendering Pipeline**
   - User code only declares views
   - Framework handles:
     - Layout calculation (via Yoga)
     - Buffer management
     - Differential rendering
     - Terminal manipulation

### Component Roadmap

**Phase 1 - Core Components** (Current)
- [x] Text
- [x] VStack, HStack
- [x] Spacer
- [ ] TextField (with proper binding)
- [ ] Button

**Phase 2 - Essential Modifiers**
- [x] .padding()
- [x] .border()
- [x] .background()
- [ ] .foregroundColor()
- [ ] .frame(width:height:)

**Phase 3 - Advanced Features**
- [ ] @State property wrapper
- [ ] @Binding support
- [ ] ForEach
- [ ] ScrollView
- [ ] List

## Technical Architecture (Internal)

### Current State (To Be Refactored)
- `LayoutView` protocol with explicit `render` and `paint` methods
- Direct Yoga node manipulation in view code
- Manual buffer management

### Target State
- Pure `View` protocol with `body: some View`
- Yoga encapsulated in internal layout engine
- Automatic rendering pipeline
- View diffing for optimal performance

### Migration Path
1. Create new `View` protocol alongside existing `LayoutView`
2. Implement internal renderer that bridges new API to existing engine
3. Gradually migrate all components to new API
4. Deprecate and remove old `LayoutView` system

## Usage Examples (Target API)

### Hello World
```swift
import SwiftTUI

struct HelloApp: View {
    var body: some View {
        Text("Hello, Terminal!")
            .foregroundColor(.cyan)
            .padding()
            .border()
    }
}

// In main.swift
SwiftTUI.run(HelloApp())
```

### Interactive Form
```swift
struct FormView: View {
    @State private var username = ""
    @State private var age = ""
    
    var body: some View {
        VStack(spacing: 1) {
            Text("User Registration")
                .bold()
                .padding(.bottom, 2)
            
            HStack {
                Text("Username:")
                TextField("Enter username", text: $username)
                    .frame(width: 20)
            }
            
            HStack {
                Text("Age:")
                TextField("Enter age", text: $age)
                    .frame(width: 10)
            }
            
            Button("Submit") {
                // Handle submission
            }
            .padding(.top, 2)
        }
        .padding()
        .border()
    }
}
```

## Comparison with React Ink

```javascript
// React Ink
import React, {useState} from 'react';
import {render, Text, Box, TextInput} from 'ink';

const App = () => {
    const [name, setName] = useState('');
    
    return (
        <Box flexDirection="column" borderStyle="single">
            <Text>Hello, {name}!</Text>
            <TextInput value={name} onChange={setName} />
        </Box>
    );
};

render(<App />);
```

```swift
// SwiftTUI (Target)
import SwiftTUI

struct App: View {
    @State private var name = ""
    
    var body: some View {
        VStack {
            Text("Hello, \(name)!")
            TextField("Enter name", text: $name)
        }
        .border()
    }
}

SwiftTUI.run(App())
```

## Internal Implementation Notes

- Yoga is used internally for layout calculations but NEVER exposed in public API
- Terminal manipulation uses ANSI escape sequences
- Differential rendering optimizes performance
- Event loop handles keyboard input and state updates

## Testing Guidelines

- Test public API behavior, not internal implementation
- Ensure SwiftUI compatibility in API design
- Performance tests for rendering large view hierarchies
- Integration tests for terminal output

## DO NOT

- Expose Yoga types in public API
- Require users to call render methods
- Mix imperative and declarative patterns
- Create APIs that don't exist in SwiftUI without strong justification