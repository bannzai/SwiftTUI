/// RenderNode システムで使用される基本的な型定義
///
/// このファイルには、新アーキテクチャで使用される基本的な型が定義されています。
/// これらの型は、レンダリングノードの属性、レイアウト制約、パッチタイプなど、
/// システム全体で共有される構造体や列挙型を含みます。

import Foundation

// MARK: - RenderAttributes

/// レンダリングノードの視覚的属性を管理する構造体
///
/// 各RenderNodeが持つ視覚的な属性（色、スタイル、パディングなど）を
/// 一元管理します。SwiftUIのViewModifierに相当する情報を保持します。
///
/// 使用例:
/// ```swift
/// var attributes = RenderAttributes()
/// attributes.foregroundColor = .green
/// attributes.bold = true
/// ```
public struct RenderAttributes {
  /// 前景色（テキストカラー）
  public var foregroundColor: Color?
  
  /// 背景色
  public var backgroundColor: Color?
  
  /// ボールドスタイル
  public var bold: Bool = false
  
  /// アンダーラインスタイル
  public var underline: Bool = false
  
  /// パディング（内側の余白）
  public var padding: EdgeInsets = .zero
  
  /// ボーダースタイル（既存のBorderStyleを使用）
  public var border: BorderStyle?
  
  /// イニシャライザ
  public init(
    foregroundColor: Color? = nil,
    backgroundColor: Color? = nil,
    bold: Bool = false,
    underline: Bool = false,
    padding: EdgeInsets = .zero,
    border: BorderStyle? = nil
  ) {
    self.foregroundColor = foregroundColor
    self.backgroundColor = backgroundColor
    self.bold = bold
    self.underline = underline
    self.padding = padding
    self.border = border
  }
}

// MARK: - Equatable

extension RenderAttributes: Equatable {
  public static func == (lhs: RenderAttributes, rhs: RenderAttributes) -> Bool {
    return lhs.foregroundColor == rhs.foregroundColor &&
           lhs.backgroundColor == rhs.backgroundColor &&
           lhs.bold == rhs.bold &&
           lhs.underline == rhs.underline &&
           lhs.padding == rhs.padding &&
           lhs.border == rhs.border
  }
}

// MARK: - LayoutConstraints

/// レイアウト計算時の制約を表す構造体
///
/// 親ノードから子ノードに渡される、利用可能なスペースの制約を定義します。
/// SwiftUIのProposedViewSizeに相当します。
///
/// 使用例:
/// ```swift
/// let constraints = LayoutConstraints(maxWidth: 80, maxHeight: 24)
/// node.layout(constraints: constraints)
/// ```
public struct LayoutConstraints: Equatable {
  /// 最大幅（文字数）
  public let maxWidth: Int
  
  /// 最大高さ（行数）
  public let maxHeight: Int
  
  /// 最小幅（文字数）
  public let minWidth: Int
  
  /// 最小高さ（行数）
  public let minHeight: Int
  
  /// イニシャライザ
  public init(
    minWidth: Int = 0,
    maxWidth: Int = .max,
    minHeight: Int = 0,
    maxHeight: Int = .max
  ) {
    self.minWidth = minWidth
    self.maxWidth = maxWidth
    self.minHeight = minHeight
    self.maxHeight = maxHeight
  }
  
  /// 無制限の制約
  public static var unconstrained: LayoutConstraints {
    LayoutConstraints()
  }
  
  /// 固定サイズの制約
  public static func fixed(width: Int, height: Int) -> LayoutConstraints {
    LayoutConstraints(
      minWidth: width,
      maxWidth: width,
      minHeight: height,
      maxHeight: height
    )
  }
}

// MARK: - EdgeInsets

/// エッジごとの余白を定義する構造体
///
/// SwiftUIのEdgeInsetsと同等の機能を提供します。
/// ターミナルでは文字単位でのインセットになります。
public struct EdgeInsets: Equatable {
  /// 上部の余白（行数）
  public let top: Int
  
  /// 左側の余白（文字数）
  public let leading: Int
  
  /// 下部の余白（行数）
  public let bottom: Int
  
  /// 右側の余白（文字数）
  public let trailing: Int
  
  /// イニシャライザ
  public init(top: Int = 0, leading: Int = 0, bottom: Int = 0, trailing: Int = 0) {
    self.top = top
    self.leading = leading
    self.bottom = bottom
    self.trailing = trailing
  }
  
  /// ゼロ余白
  public static var zero: EdgeInsets {
    EdgeInsets()
  }
  
  /// 全方向に同じ余白
  public static func all(_ value: Int) -> EdgeInsets {
    EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
  }
  
  /// 水平方向の合計
  public var horizontal: Int { leading + trailing }
  
  /// 垂直方向の合計
  public var vertical: Int { top + bottom }
}

// NOTE: BorderStyleは既存の定義を使用

// MARK: - Size

/// サイズを表す構造体
///
/// ターミナルでのサイズは文字数と行数で表現されます。
public struct Size: Equatable {
  /// 幅（文字数）
  public let width: Int
  
  /// 高さ（行数）
  public let height: Int
  
  /// イニシャライザ
  public init(width: Int, height: Int) {
    self.width = width
    self.height = height
  }
  
  /// ゼロサイズ
  public static var zero: Size {
    Size(width: 0, height: 0)
  }
}

// MARK: - Frame

/// フレーム（位置とサイズ）を表す構造体
///
/// CGRectの代わりにターミナル座標系で使用します。
public struct Frame: Equatable {
  /// 原点
  public var origin: Point
  
  /// サイズ
  public var size: Size
  
  /// イニシャライザ
  public init(origin: Point, size: Size) {
    self.origin = origin
    self.size = size
  }
  
  /// 座標とサイズから初期化
  public init(x: Int, y: Int, width: Int, height: Int) {
    self.origin = Point(x: x, y: y)
    self.size = Size(width: width, height: height)
  }
  
  /// ゼロフレーム
  public static var zero: Frame {
    Frame(origin: .zero, size: .zero)
  }
  
  /// X座標
  public var x: Int { origin.x }
  
  /// Y座標
  public var y: Int { origin.y }
  
  /// 幅
  public var width: Int { size.width }
  
  /// 高さ
  public var height: Int { size.height }
  
  /// 最大X座標
  public var maxX: Int { x + width }
  
  /// 最大Y座標
  public var maxY: Int { y + height }
}

// MARK: - Point

/// 2D座標を表す構造体
///
/// ターミナルでの座標系（列、行）を表現します。
public struct Point: Equatable {
  /// X座標（列番号）
  public let x: Int
  
  /// Y座標（行番号）
  public let y: Int
  
  /// イニシャライザ
  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }
  
  /// ゼロ原点
  public static var zero: Point {
    Point(x: 0, y: 0)
  }
}