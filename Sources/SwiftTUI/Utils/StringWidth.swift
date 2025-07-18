/// 文字列の表示幅を計算するユーティリティ
///
/// ターミナルでの文字の表示幅は、文字によって異なります：
/// - 半角文字（ASCII）: 1幅
/// - 全角文字（日本語、中国語など）: 2幅
/// - 絵文字: 基本的に2幅（一部例外あり）
/// - 制御文字: 0幅

import Foundation

/// 文字列の実際の表示幅を計算
///
/// - Parameter string: 幅を計算したい文字列
/// - Returns: ターミナルでの表示幅
public func stringWidth(_ string: String) -> Int {
  var width = 0

  for scalar in string.unicodeScalars {
    width += scalarWidth(scalar)
  }

  return width
}

/// Unicode Scalarの表示幅を計算
///
/// East Asian Widthに基づいて文字幅を判定します
public func scalarWidth(_ scalar: Unicode.Scalar) -> Int {
  let value = scalar.value

  // 制御文字
  if value < 0x20 || (0x7F <= value && value < 0xA0) {
    return 0
  }

  // ASCII範囲（基本的に1幅）
  if value < 0x7F {
    return 1
  }

  // CJK統合漢字、ひらがな、カタカナ、全角記号など
  // これらは2幅として扱う
  if (0x1100 <= value && value <= 0x115F)  // ハングル
    || (0x2E80 <= value && value <= 0x303E)  // CJK記号と句読点
    || (0x3040 <= value && value <= 0x309F)  // ひらがな
    || (0x30A0 <= value && value <= 0x30FF)  // カタカナ
    || (0x3130 <= value && value <= 0x318F)  // ハングル互換字母
    || (0x3200 <= value && value <= 0x32FF)  // 囲みCJK文字・月名
    || (0x3400 <= value && value <= 0x4DBF)  // CJK統合漢字拡張A
    || (0x4E00 <= value && value <= 0x9FFF)  // CJK統合漢字
    || (0xAC00 <= value && value <= 0xD7AF)  // ハングル音節文字
    || (0xF900 <= value && value <= 0xFAFF)  // CJK互換漢字
    || (0xFE30 <= value && value <= 0xFE4F)  // CJK互換形
    || (0xFF00 <= value && value <= 0xFF60)  // 全角ASCII、全角句読点
    || (0xFFE0 <= value && value <= 0xFFE6)
  {  // 全角記号
    return 2
  }

  // 絵文字（基本的に2幅として扱う）
  if (0x1F300 <= value && value <= 0x1F9FF)  // 絵文字
    || (0x1F000 <= value && value <= 0x1F02F)  // 麻雀牌
    || (0x1F0A0 <= value && value <= 0x1F0FF)  // トランプ
    || (0x1F100 <= value && value <= 0x1F1FF)  // 囲み英数字
    || (0x1F200 <= value && value <= 0x1F2FF)  // 囲みCJK文字
    || (0x1F600 <= value && value <= 0x1F64F)  // 顔文字
    || (0x1F680 <= value && value <= 0x1F6FF)  // 交通・地図記号
    || (0x1F900 <= value && value <= 0x1F9FF)
  {  // 補助記号・絵文字
    return 2
  }

  // その他は1幅として扱う
  return 1
}

/// 文字列を指定幅に切り詰める
///
/// - Parameters:
///   - string: 切り詰めたい文字列
///   - maxWidth: 最大表示幅
/// - Returns: 切り詰められた文字列
public func truncateToWidth(_ string: String, maxWidth: Int) -> String {
  var currentWidth = 0
  var result = ""

  for scalar in string.unicodeScalars {
    let charWidth = scalarWidth(scalar)
    if currentWidth + charWidth > maxWidth {
      break
    }
    currentWidth += charWidth
    result.append(Character(scalar))
  }

  return result
}

/// 文字列を指定幅になるようにパディング
///
/// - Parameters:
///   - string: パディングしたい文字列
///   - width: 目標の表示幅
///   - alignment: 配置（.left, .center, .right）
/// - Returns: パディングされた文字列
public func padToWidth(_ string: String, width: Int, alignment: TextAlignment = .left) -> String {
  let currentWidth = stringWidth(string)

  if currentWidth >= width {
    return truncateToWidth(string, maxWidth: width)
  }

  let padding = width - currentWidth

  switch alignment {
  case .left:
    return string + String(repeating: " ", count: padding)
  case .center:
    let leftPad = padding / 2
    let rightPad = padding - leftPad
    return String(repeating: " ", count: leftPad) + string + String(repeating: " ", count: rightPad)
  case .right:
    return String(repeating: " ", count: padding) + string
  }
}

/// テキストの配置
public enum TextAlignment {
  case left
  case center
  case right
}
