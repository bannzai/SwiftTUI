# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SwiftTUI is a Terminal User Interface (TUI) library for Swift that enables declarative UI development using SwiftUI-like syntax, similar to React Ink. It uses Facebook's Yoga layout engine for flexbox-based layouts.

## Common Development Commands

```bash
# Build the library and executable
make install  # or: swift build

# Run the example app (builds first if needed)
make run-example  # or: swift run ExampleApp

# Run tests
swift test
```

## Architecture

### Core Components

1. **View Protocol** (`Sources/SwiftTUI/Primitives/View.swift`)
   - Base protocol requiring `render(into:)` method for buffer rendering
   - Optional `handle(event:)` for keyboard input handling

2. **LayoutView Protocol** 
   - Extension of View that integrates with Yoga layout system
   - Requires `makeNode() -> YogaNode` and `paint(origin:into:)`

3. **RenderLoop** (`Sources/SwiftTUI/Runtime/RenderLoop.swift`)
   - Central render loop using differential updates
   - Handles mounting views, scheduling redraws, and input processing
   - Uses ANSI escape sequences for terminal manipulation

4. **Layout System**
   - Uses Yoga flexbox layout engine for positioning
   - YogaNode wrapper provides Swift-friendly API

### Component Structure

**Primitives**: Basic building blocks
- Text, HStack, VStack, Spacer
- ViewBuilder for @resultBuilder syntax

**Modifiers**: View appearance
- Border, Padding
- Background color support

**Runtime**: Core functionality  
- Buffer: Line-based rendering output
- State: SwiftUI-like state management
- InputLoop: Keyboard event handling with raw terminal mode

## Key Implementation Patterns

- Views render into string buffers (array of lines)
- Layout calculation happens before rendering using Yoga
- Differential rendering only updates changed lines
- Keyboard events bubble through view hierarchy
- Use `RenderLoop.shutdown()` for safe termination (restores terminal)

## Supported Components (v0.0.1 targets)

Essential: Text, VStack, HStack, TextField, BackgroundModifier
Not planned: LazyVStack, GroupedBox, Form, containerRelative()