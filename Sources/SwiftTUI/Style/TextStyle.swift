// Sources/SwiftTUI/Styling/TextStyle.swift
public struct TextStyle: OptionSet {
  public let rawValue: Int
  public init(rawValue: Int) { self.rawValue = rawValue }

  public static let bold = TextStyle(rawValue: 1 << 0)
  public static let underline = TextStyle(rawValue: 1 << 1)
  // 拡張用にビットを空けておく

  /// ANSI SGR コード列
  func sgr() -> [String] {
    var codes: [String] = []
    if contains(.bold) { codes.append("1") }
    if contains(.underline) { codes.append("4") }
    return codes
  }
}
