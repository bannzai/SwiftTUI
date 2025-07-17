/// VStack：縦方向に子Viewを配置するコンテナ
///
/// SwiftUIと同じように、複数のViewを縦に並べて表示します。
///
/// 使用例：
/// ```swift
/// VStack {
///     Text("1行目")
///     Text("2行目")
///     Text("3行目")
/// }
/// ```
///
/// 特徴：
/// - 子Viewを上から下へ順番に配置
/// - spacingで要素間の間隔を指定可能
/// - alignmentで水平方向の配置を指定
///
/// TUI初心者向け解説：
/// - ターミナルでは文字は自然に縦に並ぶ
/// - VStackはFlexboxレイアウトでより高度な制御を実現
/// - Spacerやframeモディファイアと組み合わせることで柔軟なレイアウトが可能
public struct VStack<Content: View>: View {
  /// 子Viewのコンテンツ
  ///
  /// @ViewBuilderで生成された複数のViewを保持。
  /// Contentは通常TupleViewまたは単一のView型。
  internal let content: Content

  /// 要素間の間隔（文字単位）
  ///
  /// 各子Viewの間に挿入される空白の行数。
  /// 0の場合は間隔なし。
  internal let spacing: Int

  /// 水平方向の配置
  ///
  /// .leading: 左寄せ
  /// .center: 中央揃え（デフォルト）
  /// .trailing: 右寄せ
  internal let alignment: HorizontalAlignment

  /// VStackのイニシャライザ
  ///
  /// - Parameters:
  ///   - alignment: 水平方向の配置（デフォルト: .center）
  ///   - spacing: 要素間の間隔（デフォルト: 0）
  ///   - content: 子Viewを生成するクロージャ
  ///
  /// @ViewBuilderの説明：
  /// - 複数のViewを返すことができる特殊なクロージャ
  /// - if文やForEachも使用可能
  /// - 内部でTupleViewに変換される
  public init(
    alignment: HorizontalAlignment = .center,
    spacing: Int = 0,
    @ViewBuilder content: () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()  // クロージャを実行してViewを生成
  }

  /// VStackはプリミティブView
  ///
  /// Body = Neverの意味：
  /// - VStack自体が最終的なコンテナ
  /// - bodyプロパティを持たない
  /// - ViewRendererが直接LayoutViewに変換
  public typealias Body = Never
}

// HorizontalAlignmentはFrameModifier.swiftで定義済み

/// VStackの内部実装：セルベースのFlexStackへの変換
///
/// このextensionは、SwiftUIスタイルのVStackを
/// 実際に描画可能なCellFlexStackに変換します。
extension VStack {
  /// VStackをLayoutViewに変換
  ///
  /// 処理の流れ：
  /// 1. 子View（content）をLayoutViewに変換
  /// 2. TupleLayoutViewの場合は子要素を展開
  /// 3. CellFlexStack（縦方向）として返す
  internal var _layoutView: any LayoutView {
    // ステップ1: contentをLayoutViewに変換
    // ViewRendererがViewの種類を判別して適切に処理
    let contentLayoutView = ViewRenderer.renderView(content)

    // ステップ2: CellFlexStackを作成
    // CellFlexStackはセルベースレンダリングをサポートするFlexboxコンテナ
    return CellFlexStack(.column, spacing: Float(spacing)) {
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
