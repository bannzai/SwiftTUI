import Foundation

/// SwiftUIライクなTextField
public struct TextField: View {
    private let placeholder: String
    @Binding var text: String
    private let id = UUID().uuidString
    
    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    public typealias Body = Never
    
    internal var _layoutView: any LayoutView {
        TextFieldLayoutView(
            placeholder: placeholder,
            text: _text,
            id: id
        )
    }
}

/// TextFieldのLayoutView実装
internal class TextFieldLayoutView: LayoutView, CellLayoutView, FocusableView {
    let placeholder: String
    let text: Binding<String>
    let id: String
    private var isFocused = false
    private var cursorPosition = 0
    
    init(placeholder: String, text: Binding<String>, id: String) {
        self.placeholder = placeholder
        self.text = text
        self.id = id
        
        // カーソル位置を文字列の最後に設定
        self.cursorPosition = text.wrappedValue.count
        
        // FocusManagerに登録
        FocusManager.shared.register(self, id: id, acceptsInput: true)
    }
    
    deinit {
        // FocusManagerから削除
        FocusManager.shared.unregister(id: id)
    }
    
    // MARK: - LayoutView
    
    func makeNode() -> YogaNode {
        let node = YogaNode()
        let displayText = text.wrappedValue.isEmpty ? placeholder : text.wrappedValue
        let width = Float(displayText.count + 4) // 枠線とパディング分
        node.setSize(width: width, height: 3) // 枠線含めて3行
        node.setMinHeight(3)
        return node
    }
    
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        let displayText = text.wrappedValue.isEmpty ? placeholder : text.wrappedValue
        let isPlaceholder = text.wrappedValue.isEmpty
        
        // 枠線の色（フォーカス時は青、非フォーカス時はグレー）
        let borderColor = isFocused ? "\u{1B}[94m" : "\u{1B}[90m" // 青 or グレー
        let resetColor = "\u{1B}[0m"
        
        // テキストの色（プレースホルダーはグレー）
        let textColor = isPlaceholder ? "\u{1B}[90m" : ""
        
        // 上の枠線
        let topBorder = borderColor + "┌" + String(repeating: "─", count: displayText.count + 2) + "┐" + resetColor
        bufferWrite(row: origin.y, col: origin.x, text: topBorder, into: &buffer)
        
        // テキスト行
        var textLine = borderColor + "│" + resetColor + " "
        
        if isFocused && !isPlaceholder {
            // カーソル位置でテキストを分割
            let beforeCursor = String(text.wrappedValue.prefix(cursorPosition))
            let atCursor = cursorPosition < text.wrappedValue.count 
                ? String(text.wrappedValue[text.wrappedValue.index(text.wrappedValue.startIndex, offsetBy: cursorPosition)])
                : " "
            let afterCursor = cursorPosition < text.wrappedValue.count - 1
                ? String(text.wrappedValue.suffix(text.wrappedValue.count - cursorPosition - 1))
                : ""
            
            // カーソル位置を反転表示
            textLine += textColor + beforeCursor + "\u{1B}[7m" + atCursor + "\u{1B}[0m" + textColor + afterCursor
        } else {
            textLine += textColor + displayText + resetColor
        }
        
        // パディングを追加
        let remainingSpace = displayText.count - text.wrappedValue.count
        if remainingSpace > 0 {
            textLine += String(repeating: " ", count: remainingSpace)
        }
        
        textLine += " " + borderColor + "│" + resetColor
        bufferWrite(row: origin.y + 1, col: origin.x, text: textLine, into: &buffer)
        
        // 下の枠線
        let bottomBorder = borderColor + "└" + String(repeating: "─", count: displayText.count + 2) + "┘" + resetColor
        bufferWrite(row: origin.y + 2, col: origin.x, text: bottomBorder, into: &buffer)
    }
    
    func render(into buffer: inout [String]) {
        // LayoutViewプロトコルの要件
    }
    
    // MARK: - CellLayoutView
    
    func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
        let displayText = text.wrappedValue.isEmpty ? placeholder : text.wrappedValue
        let isPlaceholder = text.wrappedValue.isEmpty
        
        // 枠線の色（フォーカス時は青、非フォーカス時は白）
        let borderColor = isFocused ? Color.blue : Color.white
        
        // テキストの色（プレースホルダーは白）
        let textColor = isPlaceholder ? Color.white : nil
        
        // 上の枠線
        buffer.setCell(row: origin.y, col: origin.x, cell: Cell(character: "┌", foregroundColor: borderColor))
        for i in 1...(displayText.count + 2) {
            buffer.setCell(row: origin.y, col: origin.x + i, cell: Cell(character: "─", foregroundColor: borderColor))
        }
        buffer.setCell(row: origin.y, col: origin.x + displayText.count + 3, cell: Cell(character: "┐", foregroundColor: borderColor))
        
        // テキスト行
        buffer.setCell(row: origin.y + 1, col: origin.x, cell: Cell(character: "│", foregroundColor: borderColor))
        buffer.setCell(row: origin.y + 1, col: origin.x + 1, cell: Cell(character: " "))
        
        if isFocused && !isPlaceholder {
            // カーソル位置でテキストを分割して表示
            for (index, char) in displayText.enumerated() {
                if index == cursorPosition {
                    // カーソル位置は反転表示（背景色を設定）
                    buffer.setCell(row: origin.y + 1, col: origin.x + 2 + index, 
                                  cell: Cell(character: char, 
                                            foregroundColor: Color.black,
                                            backgroundColor: Color.white))
                } else {
                    buffer.setCell(row: origin.y + 1, col: origin.x + 2 + index, 
                                  cell: Cell(character: char,
                                            foregroundColor: textColor))
                }
            }
            
            // カーソルが文字列の最後にある場合
            if cursorPosition == displayText.count {
                buffer.setCell(row: origin.y + 1, col: origin.x + 2 + cursorPosition,
                              cell: Cell(character: " ",
                                        foregroundColor: Color.black,
                                        backgroundColor: Color.white))
            }
        } else {
            // 通常のテキスト表示
            for (index, char) in displayText.enumerated() {
                buffer.setCell(row: origin.y + 1, col: origin.x + 2 + index, 
                              cell: Cell(character: char,
                                        foregroundColor: textColor))
            }
        }
        
        buffer.setCell(row: origin.y + 1, col: origin.x + displayText.count + 2, cell: Cell(character: " "))
        buffer.setCell(row: origin.y + 1, col: origin.x + displayText.count + 3, cell: Cell(character: "│", foregroundColor: borderColor))
        
        // 下の枠線
        buffer.setCell(row: origin.y + 2, col: origin.x, cell: Cell(character: "└", foregroundColor: borderColor))
        for i in 1...(displayText.count + 2) {
            buffer.setCell(row: origin.y + 2, col: origin.x + i, cell: Cell(character: "─", foregroundColor: borderColor))
        }
        buffer.setCell(row: origin.y + 2, col: origin.x + displayText.count + 3, cell: Cell(character: "┘", foregroundColor: borderColor))
    }
    
    // MARK: - FocusableView
    
    func setFocused(_ focused: Bool) {
        isFocused = focused
    }
    
    func handleKeyEvent(_ event: KeyboardEvent) -> Bool {
        guard isFocused else { return false }
        
        switch event.key {
        case .char(let c):
            // 文字を挿入
            let index = text.wrappedValue.index(text.wrappedValue.startIndex, offsetBy: cursorPosition)
            text.wrappedValue.insert(c, at: index)
            cursorPosition += 1
            return true
            
        case .backspace:
            // カーソル位置の前の文字を削除
            if cursorPosition > 0 {
                let index = text.wrappedValue.index(text.wrappedValue.startIndex, offsetBy: cursorPosition - 1)
                text.wrappedValue.remove(at: index)
                cursorPosition -= 1
            }
            return true
            
        case .delete:
            // カーソル位置の文字を削除
            if cursorPosition < text.wrappedValue.count {
                let index = text.wrappedValue.index(text.wrappedValue.startIndex, offsetBy: cursorPosition)
                text.wrappedValue.remove(at: index)
            }
            return true
            
        case .left:
            // カーソルを左に移動
            if cursorPosition > 0 {
                cursorPosition -= 1
            }
            return true
            
        case .right:
            // カーソルを右に移動
            if cursorPosition < text.wrappedValue.count {
                cursorPosition += 1
            }
            return true
            
        case .home:
            // カーソルを行頭に移動
            cursorPosition = 0
            return true
            
        case .end:
            // カーソルを行末に移動
            cursorPosition = text.wrappedValue.count
            return true
            
        default:
            return false
        }
    }
}