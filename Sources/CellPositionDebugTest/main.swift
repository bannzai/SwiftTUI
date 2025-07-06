import SwiftTUI
import yoga

// カスタムのデバッグビュー
struct DebugText: CellLayoutView {
    let text: String
    let color: Color
    
    func makeNode() -> YogaNode {
        let node = YogaNode()
        node.setSize(width: Float(text.count), height: 1)
        return node
    }
    
    func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
        print("DebugText.paintCells: text='\(text)' color=\(color) origin=(\(origin.x), \(origin.y))")
        bufferWriteCell(
            row: origin.y,
            col: origin.x,
            text: text,
            backgroundColor: color,
            into: &buffer
        )
    }
    
    func handle(event: KeyboardEvent) -> Bool { false }
}

// カスタムのHStack
struct DebugHStack: CellLayoutView {
    let children: [DebugText]
    
    func makeNode() -> YogaNode {
        let node = YogaNode()
        node.flexDirection(.row)
        
        for child in children {
            node.insert(child: child.makeNode())
        }
        
        return node
    }
    
    func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
        print("DebugHStack.paintCells: origin=(\(origin.x), \(origin.y))")
        
        let node = makeNode()
        node.calculate(width: 80)
        
        // 各子要素の位置を確認
        let count = Int(YGNodeGetChildCount(node.rawPtr))
        for i in 0..<count {
            guard let childNode = YGNodeGetChild(node.rawPtr, Int(i)) else { continue }
            
            let left = YGNodeLayoutGetLeft(childNode)
            let top = YGNodeLayoutGetTop(childNode)
            let width = YGNodeLayoutGetWidth(childNode)
            let height = YGNodeLayoutGetHeight(childNode)
            
            print("  Child \(i): left=\(left), top=\(top), width=\(width), height=\(height)")
            
            guard left.isFinite && top.isFinite else { continue }
            
            let childOrigin = (
                x: origin.x + Int(left.rounded()),
                y: origin.y + Int(top.rounded())
            )
            
            children[i].paintCells(origin: childOrigin, into: &buffer)
        }
    }
    
    func handle(event: KeyboardEvent) -> Bool { false }
}

// テスト実行
var buffer = CellBuffer(width: 20, height: 5)

let hstack = DebugHStack(children: [
    DebugText(text: "A", color: .red),
    DebugText(text: "B", color: .green),
    DebugText(text: "C", color: .blue)
])

hstack.paintCells(origin: (0, 0), into: &buffer)

print("\n--- Buffer Contents ---")
for row in 0..<1 {
    print("Row \(row):")
    for col in 0..<10 {
        if let cell = buffer.getCell(row: row, col: col) {
            print("  Col \(col): '\(cell.character)' bg=\(String(describing: cell.backgroundColor))")
        }
    }
}

print("\n--- ANSI Output ---")
let lines = buffer.toANSILines()
for (index, line) in lines.enumerated() {
    print("Line \(index): \(line)")
}

exit(0)