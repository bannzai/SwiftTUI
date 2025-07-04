import SwiftTUI
import yoga

// Debug program to understand the issue
let child = Text("Hello")
let padding = PaddingView(1, child)

// Create and calculate node
let node1 = padding.makeNode()
node1.calculate(width: 80)
print("Node1 after calculate:")
print("Frame:", node1.frame)
if let raw = YGNodeGetChild(node1.rawPtr, 0) {
    print("Child offset: dx=\(YGNodeLayoutGetLeft(raw)), dy=\(YGNodeLayoutGetTop(raw))")
}

// Create a new node (what happens in paint)
let node2 = padding.makeNode()
print("\nNode2 (new node, not calculated):")
print("Frame:", node2.frame)
if let raw = YGNodeGetChild(node2.rawPtr, 0) {
    print("Child offset: dx=\(YGNodeLayoutGetLeft(raw)), dy=\(YGNodeLayoutGetTop(raw))")
}

// Now with BorderView
let border = BorderView(child)
let node3 = border.makeNode()
node3.calculate(width: 80)
print("\n\nBorderView node after calculate:")
print("Frame:", node3.frame)
if let raw = YGNodeGetChild(node3.rawPtr, 0) {
    print("Child offset: dx=\(YGNodeLayoutGetLeft(raw)), dy=\(YGNodeLayoutGetTop(raw))")
}