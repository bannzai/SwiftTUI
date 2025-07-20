/// CellBuffer+Extension：CellBufferの拡張
///
/// 新しいRenderNodeシステムで必要なCellBufferの拡張機能を提供します。

import Foundation

// MARK: - CellBuffer Extensions

extension CellBuffer {
  /// バッファのコピーを作成
  ///
  /// 差分計算のために、現在のバッファの完全なコピーを作成します。
  ///
  /// - Returns: コピーされたCellBuffer
  public func copy() -> CellBuffer {
    var newBuffer = CellBuffer(width: width, height: height)
    
    // すべてのセルをコピー
    for y in 0..<height {
      for x in 0..<width {
        if let cell = getCell(row: y, col: x) {
          newBuffer.setCell(row: y, col: x, cell: cell)
        }
      }
    }
    
    return newBuffer
  }
  
  /// 指定位置のセルを取得（x,y座標版）
  ///
  /// - Parameters:
  ///   - x: X座標（col）
  ///   - y: Y座標（row）
  /// - Returns: 指定位置のセル（範囲外の場合はデフォルトセル）
  public func getCell(x: Int, y: Int) -> Cell {
    // 既存のgetCellメソッドを使用
    return getCell(row: y, col: x) ?? Cell(character: " ")
  }
  
  /// セルを設定（x,y座標版）
  ///
  /// - Parameters:
  ///   - x: X座標（col）
  ///   - y: Y座標（row）
  ///   - cell: 設定するセル
  public mutating func setCell(x: Int, y: Int, cell: Cell) {
    setCell(row: y, col: x, cell: cell)
  }
  
  /// 矩形領域をクリア
  ///
  /// - Parameters:
  ///   - frame: クリアする領域
  ///   - clearCell: クリアに使用するセル（デフォルトは空白）
  public mutating func clear(frame: Frame, with clearCell: Cell = Cell(character: " ")) {
    for y in frame.y..<frame.maxY {
      for x in frame.x..<frame.maxX {
        setCell(x: x, y: y, cell: clearCell)
      }
    }
  }
  
  /// 矩形領域を塗りつぶし
  ///
  /// - Parameters:
  ///   - frame: 塗りつぶす領域
  ///   - color: 背景色
  public mutating func fill(frame: Frame, with color: Color) {
    let fillCell = Cell(
      character: " ",
      backgroundColor: color
    )
    
    for y in frame.y..<frame.maxY {
      for x in frame.x..<frame.maxX {
        setCell(x: x, y: y, cell: fillCell)
      }
    }
  }
  
  /// 他のCellBufferの内容をマージ
  ///
  /// - Parameters:
  ///   - other: マージするCellBuffer
  ///   - offset: マージ時のオフセット
  public mutating func merge(from other: CellBuffer, at offset: Point = .zero) {
    for y in 0..<other.height {
      for x in 0..<other.width {
        let cell = other.getCell(x: x, y: y)
        let targetX = x + offset.x
        let targetY = y + offset.y
        
        // 範囲内の場合のみ設定
        if targetX >= 0 && targetX < width &&
           targetY >= 0 && targetY < height {
          setCell(x: targetX, y: targetY, cell: cell)
        }
      }
    }
  }
  
  /// デバッグ用の文字列表現
  public var debugDescription: String {
    var result = "CellBuffer(\(width)×\(height)):\n"
    
    for y in 0..<min(height, 10) { // 最初の10行のみ表示
      var line = ""
      for x in 0..<min(width, 40) { // 最初の40文字のみ表示
        let cell = getCell(x: x, y: y)
        line += String(cell.character)
      }
      if width > 40 {
        line += "..."
      }
      result += "  \(line)\n"
    }
    
    if height > 10 {
      result += "  ...\n"
    }
    
    return result
  }
}

// MARK: - Cell Comparison

// Cell は既に Equatable に準拠しているため、拡張は不要

// MARK: - Utility Functions

/// bufferWriteCellの宣言（既存の関数を使用）
public func bufferWriteCell(
  row: Int,
  col: Int,
  text: String,
  into buffer: inout CellBuffer
) {
  // 既存の実装を使用
  // TODO: 実装の確認と必要に応じた調整
}

// MARK: - Test Support

#if DEBUG
extension CellBuffer {
  /// テスト用：指定位置の文字を取得
  public func character(at point: Point) -> Character {
    return getCell(x: point.x, y: point.y).character
  }
  
  /// テスト用：指定行のテキストを取得
  public func text(at row: Int) -> String {
    guard row >= 0 && row < height else { return "" }
    
    var text = ""
    for x in 0..<width {
      let cell = getCell(x: x, y: row)
      if cell.character != " " || !text.isEmpty {
        text.append(cell.character)
      }
    }
    
    return text.trimmingCharacters(in: .whitespaces)
  }
}
#endif