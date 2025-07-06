/// セルベースのバッファ書き込み関数
@inline(__always)
public func bufferWriteCell(
    row: Int,
    col: Int,
    text: String,
    foregroundColor: Color? = nil,
    backgroundColor: Color? = nil,
    style: TextStyle = [],
    into buffer: inout CellBuffer
) {
    // ガード：負値を許さない
    guard row >= 0, col >= 0 else { return }
    
    // ANSIエスケープシーケンスを解析しながら書き込み
    var currentCol = col
    var chars = Array(text)
    var i = 0
    
    // 現在の描画状態
    var currentFg = foregroundColor
    var currentBg = backgroundColor
    var currentStyle = style
    
    while i < chars.count && currentCol < buffer.width {
        let char = chars[i]
        
        if char == "\u{1B}" && i + 1 < chars.count && chars[i + 1] == "[" {
            // ANSIエスケープシーケンスの開始
            i += 2 // skip ESC[
            var code = ""
            
            // コードを読み取る
            while i < chars.count && chars[i] != "m" {
                code.append(chars[i])
                i += 1
            }
            
            if i < chars.count && chars[i] == "m" {
                i += 1 // skip 'm'
                
                // エスケープコードを解析
                parseANSICode(code, fg: &currentFg, bg: &currentBg, style: &currentStyle)
            }
        } else {
            // 通常の文字
            let cell = Cell(
                character: char,
                foregroundColor: currentFg,
                backgroundColor: currentBg,
                style: currentStyle
            )
            
            buffer.mergeCell(row: row, col: currentCol, newCell: cell)
            currentCol += 1
            i += 1
        }
    }
}

/// ANSIエスケープコードを解析
private func parseANSICode(
    _ code: String,
    fg: inout Color?,
    bg: inout Color?,
    style: inout TextStyle
) {
    let parts = code.split(separator: ";").compactMap { Int($0) }
    
    for part in parts {
        switch part {
        case 0: // Reset
            fg = nil
            bg = nil
            style = []
        case 1: // Bold
            style.insert(.bold)
        case 4: // Underline
            style.insert(.underline)
        case 30...37: // Foreground colors
            fg = colorFromANSI(part)
        case 40...47: // Background colors
            bg = colorFromANSI(part)
        case 90...97: // Bright foreground colors
            fg = colorFromANSI(part)
        case 100...107: // Bright background colors
            bg = colorFromANSI(part)
        default:
            break
        }
    }
}

/// ANSIコードからColorを取得
private func colorFromANSI(_ code: Int) -> Color? {
    switch code {
    // 標準色（前景）
    case 30: return .black
    case 31: return .red
    case 32: return .green
    case 33: return .yellow
    case 34: return .blue
    case 35: return .magenta
    case 36: return .cyan
    case 37: return .white
    
    // 標準色（背景）
    case 40: return .black
    case 41: return .red
    case 42: return .green
    case 43: return .yellow
    case 44: return .blue
    case 45: return .magenta
    case 46: return .cyan
    case 47: return .white
    
    // 明るい色（前景）
    case 90: return .black  // bright black (gray)
    case 91: return .red    // bright red
    case 92: return .green  // bright green
    case 93: return .yellow // bright yellow
    case 94: return .blue   // bright blue
    case 95: return .magenta // bright magenta
    case 96: return .cyan   // bright cyan
    case 97: return .white  // bright white
    
    // 明るい色（背景）
    case 100: return .black  // bright black (gray)
    case 101: return .red    // bright red
    case 102: return .green  // bright green
    case 103: return .yellow // bright yellow
    case 104: return .blue   // bright blue
    case 105: return .magenta // bright magenta
    case 106: return .cyan   // bright cyan
    case 107: return .white  // bright white
    
    default: return nil
    }
}

/// 背景色のみを指定範囲に適用
public func bufferFillBackground(
    row: Int,
    col: Int,
    width: Int,
    height: Int,
    color: Color,
    into buffer: inout CellBuffer
) {
    for r in row..<(row + height) {
        for c in col..<(col + width) {
            if let existingCell = buffer.getCell(row: r, col: c) {
                var newCell = existingCell
                newCell.backgroundColor = color
                buffer.setCell(row: r, col: c, cell: newCell)
            } else {
                let newCell = Cell(character: " ", backgroundColor: color)
                buffer.setCell(row: r, col: c, cell: newCell)
            }
        }
    }
}

/// ボーダーを描画（セル単位）
public func bufferDrawBorder(
    row: Int,
    col: Int,
    width: Int,
    height: Int,
    style: BorderStyle = .single,
    color: Color? = nil,
    into buffer: inout CellBuffer
) {
    let chars = borderCharacters(for: style)
    
    // 上辺
    bufferWriteCell(row: row, col: col, text: chars.topLeft, foregroundColor: color, into: &buffer)
    for c in 1..<(width - 1) {
        bufferWriteCell(row: row, col: col + c, text: chars.horizontal, foregroundColor: color, into: &buffer)
    }
    bufferWriteCell(row: row, col: col + width - 1, text: chars.topRight, foregroundColor: color, into: &buffer)
    
    // 側面
    for r in 1..<(height - 1) {
        bufferWriteCell(row: row + r, col: col, text: chars.vertical, foregroundColor: color, into: &buffer)
        bufferWriteCell(row: row + r, col: col + width - 1, text: chars.vertical, foregroundColor: color, into: &buffer)
    }
    
    // 下辺
    bufferWriteCell(row: row + height - 1, col: col, text: chars.bottomLeft, foregroundColor: color, into: &buffer)
    for c in 1..<(width - 1) {
        bufferWriteCell(row: row + height - 1, col: col + c, text: chars.horizontal, foregroundColor: color, into: &buffer)
    }
    bufferWriteCell(row: row + height - 1, col: col + width - 1, text: chars.bottomRight, foregroundColor: color, into: &buffer)
}

/// ボーダー文字のセット
private struct BorderCharacters {
    let horizontal: String
    let vertical: String
    let topLeft: String
    let topRight: String
    let bottomLeft: String
    let bottomRight: String
}

/// ボーダースタイルに応じた文字を取得
private func borderCharacters(for style: BorderStyle) -> BorderCharacters {
    switch style {
    case .single:
        return BorderCharacters(
            horizontal: "─",
            vertical: "│",
            topLeft: "┌",
            topRight: "┐",
            bottomLeft: "└",
            bottomRight: "┘"
        )
    case .double:
        return BorderCharacters(
            horizontal: "═",
            vertical: "║",
            topLeft: "╔",
            topRight: "╗",
            bottomLeft: "╚",
            bottomRight: "╝"
        )
    case .rounded:
        return BorderCharacters(
            horizontal: "─",
            vertical: "│",
            topLeft: "╭",
            topRight: "╮",
            bottomLeft: "╰",
            bottomRight: "╯"
        )
    case .thick:
        return BorderCharacters(
            horizontal: "━",
            vertical: "┃",
            topLeft: "┏",
            topRight: "┓",
            bottomLeft: "┗",
            bottomRight: "┛"
        )
    }
}