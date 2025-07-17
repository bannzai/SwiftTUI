import SwiftTUI
import yoga

// Test to understand layout calculation
let node = YogaNode()
node.setSize(width: 10, height: 2)

print("Before calculate:")
print("Frame:", node.frame)

node.calculate(width: 80)

print("\nAfter calculate with width 80:")
print("Frame:", node.frame)

// Test with child
let parent = YogaNode()
parent.setPadding(1, .all)

let child = YogaNode()
child.setSize(width: 10, height: 2)
parent.insert(child: child)

print("\n\nParent-child before calculate:")
print("Parent frame:", parent.frame)
print("Child frame:", child.frame)

parent.calculate(width: 80)

print("\nParent-child after calculate:")
print("Parent frame:", parent.frame)
print("Child frame:", child.frame)

if let raw = YGNodeGetChild(parent.rawPtr, 0) {
  print("Child offset: dx=\(YGNodeLayoutGetLeft(raw)), dy=\(YGNodeLayoutGetTop(raw))")
}
