/// ターミナルの1文字分の描画情報を表す構造体
public struct Cell: Equatable {
    /// 表示する文字
    public var character: Character
    
    /// 前景色（文字色）
    public var foregroundColor: Color?
    
    /// 背景色
    public var backgroundColor: Color?
    
    /// テキストスタイル
    public var style: TextStyle
    
    /// 空のセル（スペース）を作成
    public static var empty: Cell {
        Cell(character: " ", style: [])
    }
    
    public init(
        character: Character,
        foregroundColor: Color? = nil,
        backgroundColor: Color? = nil,
        style: TextStyle = []
    ) {
        self.character = character
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.style = style
    }
    
    /// ANSIエスケープシーケンス付きの文字列に変換
    public func toANSI() -> String {
        var result = ""
        var hasStyle = false
        
        // スタイルの開始
        if style.contains(.bold) {
            result += "\u{1B}[1m"
            hasStyle = true
        }
        if style.contains(.underline) {
            result += "\u{1B}[4m"
            hasStyle = true
        }
        
        // 色の適用
        if let fg = foregroundColor {
            result += "\u{1B}[\(fg.fg)m"
            hasStyle = true
        }
        if let bg = backgroundColor {
            result += "\u{1B}[\(bg.bg)m"
            hasStyle = true
        }
        
        // 文字を追加
        result += String(character)
        
        // スタイルのリセット
        if hasStyle {
            result += "\u{1B}[0m"
        }
        
        return result
    }
}


/// セルベースのバッファ
public struct CellBuffer {
    /// 2次元配列でセルを管理
    private var cells: [[Cell]]
    
    /// バッファの幅
    public let width: Int
    
    /// バッファの高さ
    public var height: Int {
        return cells.count
    }
    
    /// 指定サイズで初期化
    public init(width: Int, height: Int) {
        self.width = width
        self.cells = Array(repeating: Array(repeating: .empty, count: width), count: height)
    }
    
    /// 行数を確保（必要に応じて拡張）
    public mutating func ensureHeight(_ height: Int) {
        while cells.count < height {
            cells.append(Array(repeating: .empty, count: width))
        }
    }
    
    /// セルを取得
    public func getCell(row: Int, col: Int) -> Cell? {
        guard row >= 0 && row < height && col >= 0 && col < width else {
            return nil
        }
        return cells[row][col]
    }
    
    /// セルを設定
    public mutating func setCell(row: Int, col: Int, cell: Cell) {
        guard row >= 0 && col >= 0 && col < width else { return }
        
        ensureHeight(row + 1)
        cells[row][col] = cell
    }
    
    /// 文字列を指定位置に書き込み（Cell単位でマージ）
    public mutating func writeText(
        row: Int,
        col: Int,
        text: String,
        foregroundColor: Color? = nil,
        backgroundColor: Color? = nil,
        style: TextStyle = []
    ) {
        var currentCol = col
        
        for char in text {
            if currentCol >= width { break }
            
            let cell = Cell(
                character: char,
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor,
                style: style
            )
            
            setCell(row: row, col: currentCol, cell: cell)
            currentCol += 1
        }
    }
    
    /// セルをマージ（既存のセルと新しいセルを合成）
    public mutating func mergeCell(row: Int, col: Int, newCell: Cell) {
        guard let existingCell = getCell(row: row, col: col) else {
            setCell(row: row, col: col, cell: newCell)
            return
        }
        
        // マージルール：
        // 1. 文字：空白以外は新しい文字を優先
        // 2. 前景色：新しい色があれば上書き
        // 3. 背景色：新しい色があれば上書き
        // 4. スタイル：OR演算で結合
        
        var mergedCell = existingCell
        
        if newCell.character != " " {
            mergedCell.character = newCell.character
        }
        
        if let newFg = newCell.foregroundColor {
            mergedCell.foregroundColor = newFg
        }
        
        if let newBg = newCell.backgroundColor {
            mergedCell.backgroundColor = newBg
        }
        
        mergedCell.style = mergedCell.style.union(newCell.style)
        
        setCell(row: row, col: col, cell: mergedCell)
    }
    
    /// ANSIエスケープシーケンス付きの文字列配列に変換
    public func toANSILines() -> [String] {
        var lines: [String] = []
        
        for (rowIndex, row) in cells.enumerated() {
            var line = ""
            var lastBg: Color? = nil
            var hasContent = false
            
            // 行の最後の非空白文字を見つける
            var lastNonSpaceIndex = -1
            for (colIndex, cell) in row.enumerated() {
                if cell.character != " " {
                    lastNonSpaceIndex = colIndex
                    hasContent = true
                }
            }
            
            // 内容がある行のみ処理
            if hasContent || rowIndex < height {
                for (colIndex, cell) in row.enumerated() {
                    // 最後の非空白文字までのみ出力
                    if colIndex > lastNonSpaceIndex && cell.character == " " && cell.backgroundColor == nil {
                        break
                    }
                    
                    // 背景色の最適化（同じ背景色が続く場合はエスケープシーケンスを省略）
                    if cell.backgroundColor != lastBg {
                        line += cell.toANSI()
                        lastBg = cell.backgroundColor
                    } else {
                        // 背景色が同じ場合は、文字と前景色のみ出力
                        var optimizedCell = cell
                        optimizedCell.backgroundColor = nil
                        line += optimizedCell.toANSI()
                    }
                }
            }
            
            lines.append(line)
        }
        
        // 末尾の空行を削除
        while lines.count > 0 && lines[lines.count - 1].isEmpty {
            lines.removeLast()
        }
        
        return lines
    }
}