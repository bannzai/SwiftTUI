// Sources/SwiftTUI/Styling/Color.swift
public enum Color {
  // 8 color ANSI (foreground)
  case black, red, green, yellow, blue, magenta, cyan, white
  // Additional colors
  case orange
  // 256色 or RGB
  case indexed(UInt8)       // 0-255
  case rgb(r: UInt8, g: UInt8, b: UInt8)

  /// ANSI フォアグラウンドコード
  var fg: String {
    switch self {
    case .black:   return "30"
    case .red:     return "31"
    case .green:   return "32"
    case .yellow:  return "33"
    case .blue:    return "34"
    case .magenta: return "35"
    case .cyan:    return "36"
    case .white:   return "37"
    case .orange:  return "38;5;208"  // Orange using 256 color
    case .indexed(let i):
      return "38;5;\(i)"
    case .rgb(let r, let g, let b):
      return "38;2;\(r);\(g);\(b)"
    }
  }

  /// ANSI バックグラウンドコード
  var bg: String {
    switch self {
    case .black:   return "40"
    case .red:     return "41"
    case .green:   return "42"
    case .yellow:  return "43"
    case .blue:    return "44"
    case .magenta: return "45"
    case .cyan:    return "46"
    case .white:   return "47"
    case .orange:  return "48;5;208"  // Orange using 256 color
    case .indexed(let i):
      return "48;5;\(i)"
    case .rgb(let r, let g, let b):
      return "48;2;\(r);\(g);\(b)"
    }
  }
}
