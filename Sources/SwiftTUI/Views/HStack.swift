/// HStack：横方向に子Viewを配置するコンテナ
///
/// SwiftUIと同じように、複数のViewを横に並べて表示します。
///
/// 使用例：
/// ```swift
/// HStack {
///     Text("[")
///     Text("OK")
///     Text("]")
/// }  // 表示: [OK]
/// ```
///
/// 特徴：
/// - 子Viewを左から右へ順番に配置
/// - spacingで要素間の間隔を指定可能
/// - alignmentで垂直方向の配置を指定
///
/// TUI初心者向け解説：
/// - ターミナルでは通常、文字は左から右に並ぶ
/// - HStackはFlexboxレイアウトで複数の要素を管理
/// - 各要素のサイズや位置を細かく制御可能
public struct HStack<Content: View>: View {
  /// 子Viewのコンテンツ
  ///
  /// @ViewBuilderで生成された複数のViewを保持。
  /// Contentは通常TupleViewまたは単一のView型。
  internal let content: Content

  /// 要素間の間隔（文字単位）
  ///
  /// 各子Viewの間に挿入される空白の文字数。
  /// 0の場合は間隔なし。
  internal let spacing: Int

  /// 垂直方向の配置
  ///
  /// .top: 上揃え
  /// .center: 中央揃え（デフォルト）
  /// .bottom: 下揃え
  internal let alignment: VerticalAlignment

  /// HStackのイニシャライザ
  ///
  /// - Parameters:
  ///   - alignment: 垂直方向の配置（デフォルト: .center）
  ///   - spacing: 要素間の間隔（デフォルト: 0）
  ///   - content: 子Viewを生成するクロージャ
  ///
  /// @ViewBuilderの説明：
  /// - 複数のViewを返すことができる特殊なクロージャ
  /// - if文やForEachも使用可能
  /// - 内部でTupleViewに変換される
  public init(
    alignment: VerticalAlignment = .center,
    spacing: Int = 0,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()  // クロージャを実行してViewを生成
  }

  /// HStackはプリミティブView
  ///
  /// Body = Neverの意味：
  /// - HStack自体が最終的なコンテナ
  /// - bodyプロパティを持たない
  /// - ViewRendererが直接LayoutViewに変換
  public typealias Body = Never
}

// VerticalAlignmentはFrameModifier.swiftで定義済み

/// HStackの内部実装：セルベースのFlexStackへの変換
///
/// このextensionは、SwiftUIスタイルのHStackを
/// 実際に描画可能なCellFlexStackに変換します。
extension HStack {
  /// HStackをLayoutViewに変換
  ///
  /// 処理の流れ：
  /// 1. 子View（content）をLayoutViewに変換
  /// 2. TupleLayoutViewの場合は子要素を展開
  /// 3. CellFlexStack（横方向）として返す
  internal var _layoutView: any LayoutView {
    // ステップ1: contentをLayoutViewに変換
    // ViewRendererがViewの種類を判別して適切に処理
    let contentLayoutView = ViewRenderer.renderView(content)

    // VerticalAlignmentをCellFlexStack.Alignmentに変換
    let flexAlignment: CellFlexStack.Alignment
    switch alignment {
    case .top:
      flexAlignment = .start
    case .center:
      flexAlignment = .center
    case .bottom:
      flexAlignment = .end
    }

    // ステップ2: CellFlexStackを作成
    // CellFlexStackはセルベースレンダリングをサポートするFlexboxコンテナ
    // .rowは横方向の配置を指定（VStackは.column）
    return CellFlexStack(.row, spacing: Float(spacing), alignment: flexAlignment) {
      // ステップ3: 子要素の展開
      // TupleLayoutViewは複数のViewを含むラッパー
      if let tupleLayoutView = contentLayoutView as? TupleLayoutView {
        // 複数のViewの場合: 配列を展開
        return tupleLayoutView.views
      } else {
        // 単一のViewの場合: 配列にラップ
        return [LegacyAnyView(contentLayoutView)]
      }
    }
  }
}
