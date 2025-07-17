/// ViewRenderer：SwiftUIライクなViewを描画可能な形式に変換するエンジン
///
/// このファイルは、SwiftTUIの変換エンジンの中心部分です。
/// 宣言的に定義されたView階層を、実際にターミナルに描画可能な
/// LayoutView階層に変換します。
///
/// 変換の流れ：
/// 1. View（SwiftUI風の宣言的定義）
/// 2. → ViewRenderer（このファイル）
/// 3. → LayoutView（Yogaレイアウト + 描画ロジック）
/// 4. → CellBuffer（実際の画面表示）
///
/// 重要な概念：
/// - プリミティブView：Text、Button等の基本的なView（Body == Never）
/// - コンポジットView：VStack、HStack等の他のViewを含むView
/// - ModifiedContent：モディファイアが適用されたView

import Foundation
import yoga  // Flexboxレイアウトエンジン

/// ViewからLayoutViewへの変換を行う内部レンダラー
///
/// structを使う理由：
/// - 状態を持たない純粋な変換処理
/// - すべてのメソッドがstatic
internal struct ViewRenderer {

  /// ViewをLayoutViewに変換するメインエントリーポイント
  ///
  /// このメソッドがView階層を再帰的に処理し、
  /// 適切なLayoutViewに変換します。
  ///
  /// - Parameter view: 変換対象のView
  /// - Returns: 描画可能なLayoutView
  static func renderView<V: View>(_ view: V) -> any LayoutView {
    // 型名を取得（リフレクションによる型判定）
    // Swiftではジェネリック型の情報が実行時に失われるため、
    // 文字列での型名判定を使用
    let typeName = String(describing: type(of: view))

    // ModifiedContentの特別扱い
    // ModifiedContent<Content, Modifier>は、モディファイアが
    // 適用されたViewを表す特殊な型
    if typeName.hasPrefix("ModifiedContent<") {
      return renderModifiedContent(view)
    }

    // EnvironmentWrapperの特別扱い
    // 環境値が設定されたViewのラッパー
    if typeName.hasPrefix("EnvironmentWrapper<") {
      return renderPrimitiveView(view)
    }

    // プリミティブViewの判定
    // Body == Neverは、そのView自体が最終的なコンテンツであることを示す
    if V.Body.self == Never.self {
      return renderPrimitiveView(view)
    }

    // コンポジットViewの場合
    // bodyプロパティを再帰的に処理
    return renderView(view.body)
  }

  /// プリミティブViewの変換
  private static func renderPrimitiveView<V: View>(_ view: V) -> any LayoutView {
    switch view {
    case let anyView as AnyView:
      return anyView.makeLayoutView()

    case is EmptyView:
      return EmptyView._LayoutView()

    case let text as Text:
      return text._layoutView

    case let textField as TextField:
      return textField._layoutView

    case let spacer as Spacer:
      return spacer._layoutView

    case let conditional as ConditionalContent<AnyView, AnyView>:
      return renderConditionalContent(conditional)

    default:
      // 型名でButtonContainerを検出
      let viewTypeName = String(describing: type(of: view))
      if viewTypeName.hasPrefix("ButtonContainer<") {
        if CellRenderLoop.DEBUG {
          print("[ViewRenderer] Detected ButtonContainer, calling renderButtonContainer")
        }
        return renderButtonContainer(view)
      }

      // 型名でConditionalContentを検出
      if viewTypeName.hasPrefix("ConditionalContent<") {
        return renderConditionalContentGeneric(view)
      }

      // 型名でModifiedContentを検出
      let typeName = String(describing: type(of: view))
      if typeName.hasPrefix("ModifiedContent<") {
        return renderModifiedContent(view)
      }

      // 型名でTupleViewを検出
      if typeName.hasPrefix("TupleView<") {
        return renderTupleViewGeneric(view)
      }

      // ForEachExpandedの検出
      if let forEachExpanded = view as? _ForEachExpandedProtocol {
        return renderForEachExpanded(forEachExpanded)
      }

      // ScrollViewの検出
      if typeName.hasPrefix("ScrollView<") {
        return renderScrollView(view)
      }

      // Listの検出
      if typeName.hasPrefix("List<") {
        return renderList(view)
      }

      // EnvironmentWrapperの処理
      if let wrapper = view as? EnvironmentWrapperProtocol {
        return wrapper.layoutView
      }

      // _layoutViewプロパティを持つViewの処理
      // VStackやHStackは_layoutViewプロパティを持っている
      // Mirrorで_layoutViewプロパティを探す
      let mirror = Mirror(reflecting: view)
      if let layoutViewChild = mirror.children.first(where: { $0.label == "_layoutView" }),
        let layoutView = layoutViewChild.value as? any LayoutView
      {
        return layoutView
      }

      // _layoutViewが見つからない場合のフォールバック
      // VStackやHStackの場合は特別な処理
      return renderStackView(view)
    }
  }

  /// ButtonContainerの変換
  private static func renderButtonContainer<V: View>(_ view: V) -> any LayoutView {
    // Mirror経由で_layoutViewプロパティを直接取得
    let mirror = Mirror(reflecting: view)

    // _layoutViewプロパティを探す
    if let layoutViewChild = mirror.children.first(where: { $0.label == "_layoutView" }),
      let layoutView = layoutViewChild.value as? any LayoutView
    {
      if CellRenderLoop.DEBUG {
        print("[ViewRenderer] Found _layoutView in ButtonContainer: \(type(of: layoutView))")
      }
      return layoutView
    }

    // フォールバック: action, label, idを取得して新規作成
    var action: (() -> Void)?
    var label: (any View)?
    var id: String?

    for child in mirror.children {
      switch child.label {
      case "action":
        action = child.value as? () -> Void
      case "label":
        label = child.value as? any View
      case "computedId":
        id = child.value as? String
      default:
        break
      }
    }

    // ButtonLayoutManagerを使用してLayoutViewを取得
    if let action = action, let label = label, let id = id {
      return ButtonLayoutManager.shared.getOrCreate(id: id, action: action, label: label)
    }

    // フォールバック
    return EmptyView._LayoutView()
  }

  /// TupleViewの変換（ジェネリック版）
  private static func renderTupleViewGeneric<V: View>(_ view: V) -> any LayoutView {
    // Mirror経由でvalueプロパティにアクセス
    let mirror = Mirror(reflecting: view)
    guard let valueChild = mirror.children.first(where: { $0.label == "value" }) else {
      return EmptyView._LayoutView()
    }

    let valueMirror = Mirror(reflecting: valueChild.value)
    var views: [LegacyAnyView] = []

    for (index, child) in valueMirror.children.enumerated() {
      if let childView = child.value as? any View {
        if CellRenderLoop.DEBUG {
          print("[ViewRenderer] TupleView child \(index): \(type(of: childView))")
        }
        let layoutView = renderView(childView)
        if CellRenderLoop.DEBUG {
          print("[ViewRenderer]   -> LayoutView: \(type(of: layoutView))")
        }
        views.append(LegacyAnyView(layoutView))
      }
    }

    // 複数のViewをTupleLayoutViewでラップ
    if views.isEmpty {
      return EmptyView._LayoutView()
    } else if views.count == 1 {
      return views[0]
    } else {
      return TupleLayoutView(views: views)
    }
  }

  /// TupleViewの変換（型安全版 - 使用されない）
  private static func renderTupleView<T>(_ tupleView: TupleView<T>) -> any LayoutView {
    let mirror = Mirror(reflecting: tupleView.value)
    var views: [LegacyAnyView] = []

    for child in mirror.children {
      if let childView = child.value as? any View {
        let layoutView = renderView(childView)
        views.append(LegacyAnyView(layoutView))
      }
    }

    // 複数のViewをFlexStackでラップ
    if views.isEmpty {
      return EmptyView._LayoutView()
    } else if views.count == 1 {
      return views[0]
    } else {
      // 複数のViewをFlexStackでラップして返す
      // VStackやHStackの内部では適切な方向に調整される
      return TupleLayoutView(views: views)
    }
  }

  /// ConditionalContentの変換
  private static func renderConditionalContent<T: View, F: View>(
    _ conditional: ConditionalContent<T, F>
  ) -> any LayoutView {
    switch conditional {
    case .first(let content):
      return renderView(content)
    case .second(let content):
      return renderView(content)
    }
  }

  /// ConditionalContentの変換（ジェネリック版）
  private static func renderConditionalContentGeneric<V: View>(_ view: V) -> any LayoutView {
    // Mirror経由でenumケースを判定
    let mirror = Mirror(reflecting: view)

    // ConditionalContentのミラーは子要素を1つ持つ
    if let child = mirror.children.first {
      if let content = child.value as? any View {
        return renderView(content)
      }
    }

    return EmptyView._LayoutView()
  }

  /// VStackやHStackの特別な処理
  private static func renderStackView<V: View>(_ view: V) -> any LayoutView {
    let typeName = String(describing: type(of: view))

    // VStackの処理
    if typeName.hasPrefix("VStack<") {
      // VStackは既に_layoutViewプロパティを持っている
      if let vstack = view as? VStack<AnyView> {
        return vstack._layoutView
      }
      // Mirror経由でcontent, spacingにアクセス
      let mirror = Mirror(reflecting: view)
      if let contentChild = mirror.children.first(where: { $0.label == "content" }),
        let content = contentChild.value as? any View
      {
        let spacing = mirror.children.first(where: { $0.label == "spacing" })?.value as? Int ?? 0
        let contentLayoutView = renderView(content)
        return CellFlexStack(.column, spacing: Float(spacing)) {
          if let tupleLayoutView = contentLayoutView as? TupleLayoutView {
            return tupleLayoutView.views
          } else {
            return [LegacyAnyView(contentLayoutView)]
          }
        }
      }
    }

    // HStackの処理
    if typeName.hasPrefix("HStack<") {
      // HStackは既に_layoutViewプロパティを持っている
      if let hstack = view as? HStack<AnyView> {
        return hstack._layoutView
      }
      // Mirror経由でcontent, spacingにアクセス
      let mirror = Mirror(reflecting: view)
      if let contentChild = mirror.children.first(where: { $0.label == "content" }),
        let content = contentChild.value as? any View
      {
        let spacing = mirror.children.first(where: { $0.label == "spacing" })?.value as? Int ?? 0
        let contentLayoutView = renderView(content)
        // DEBUG
        if CellRenderLoop.DEBUG {
          print("[ViewRenderer] Rendering HStack with content type: \(type(of: contentLayoutView))")
        }
        return CellFlexStack(.row, spacing: Float(spacing)) {
          if let tupleLayoutView = contentLayoutView as? TupleLayoutView {
            if CellRenderLoop.DEBUG {
              print(
                "[ViewRenderer] HStack contains TupleLayoutView with \(tupleLayoutView.views.count) views"
              )
            }
            return tupleLayoutView.views
          } else {
            if CellRenderLoop.DEBUG {
              print("[ViewRenderer] HStack contains single view: \(type(of: contentLayoutView))")
            }
            return [LegacyAnyView(contentLayoutView)]
          }
        }
      }
    }

    // ButtonContainerの処理
    if typeName.hasPrefix("ButtonContainer<") {
      // _layoutViewプロパティを直接使用
      let mirror = Mirror(reflecting: view)
      if let layoutViewChild = mirror.children.first(where: { $0.label == "_layoutView" }),
        let layoutView = layoutViewChild.value as? any LayoutView
      {
        return layoutView
      }
      // Mirror経由でaction, label, idにアクセス
      if let actionChild = mirror.children.first(where: { $0.label == "action" }),
        let labelChild = mirror.children.first(where: { $0.label == "label" }),
        let idChild = mirror.children.first(where: { $0.label == "id" }),
        let label = labelChild.value as? any View,
        let id = idChild.value as? String
      {
        return ButtonLayoutManager.shared.getOrCreate(
          id: id,
          action: actionChild.value as! () -> Void,
          label: label
        )
      }
    }

    // Toggleの処理
    if let toggle = view as? Toggle {
      return toggle._layoutView
    }

    // Pickerの処理
    if typeName.hasPrefix("Picker<") {
      // Mirror経由で_layoutViewプロパティを探す
      let mirror = Mirror(reflecting: view)
      if let layoutViewChild = mirror.children.first(where: { $0.label == "_layoutView" }),
        let layoutView = layoutViewChild.value as? any LayoutView
      {
        return layoutView
      }
    }

    // ProgressViewの処理
    if let progressView = view as? ProgressView {
      return progressView._layoutView
    }

    // Sliderの処理
    if typeName.hasPrefix("Slider<") {
      // Mirror経由で_layoutViewプロパティを探す
      let mirror = Mirror(reflecting: view)
      if let layoutViewChild = mirror.children.first(where: { $0.label == "_layoutView" }),
        let layoutView = layoutViewChild.value as? any LayoutView
      {
        return layoutView
      }
    }

    // Alertの処理
    if let alert = view as? Alert {
      return alert._layoutView
    }

    // 未対応のViewはEmptyViewとして扱う
    return EmptyView._LayoutView()
  }

  /// ModifiedContentの変換
  ///
  /// ModifiedContentはモディファイアが適用されたViewを表す内部型です。
  ///
  /// 例：Text("Hello").padding() の結果は
  /// ModifiedContent<Text, PaddingModifier> 型になります。
  ///
  /// 処理の流れ：
  /// 1. Mirrorでcontent（元のView）とmodifierを取得
  /// 2. contentを先にLayoutViewに変換
  /// 3. modifierの種類に応じて適切なラッパーLayoutViewを作成
  /// 4. モディファイアが適用されたLayoutViewを返す
  ///
  /// TUI初心者向け解説：
  /// - モディファイアはデコレーターパターンの一種
  /// - 元のViewをラップして新しい機能を追加
  /// - .padding()や.border()などのメソッド呼び出しがモディファイアを生成
  private static func renderModifiedContent<V: View>(_ view: V) -> any LayoutView {
    // Mirrorを使ってModifiedContentの内部構造にアクセス
    // ModifiedContentは以下の2つのプロパティを持つ：
    // - content: モディファイアが適用される元のView
    // - modifier: 適用されるモディファイア
    let mirror = Mirror(reflecting: view)

    // contentとmodifierを取得
    guard let contentChild = mirror.children.first(where: { $0.label == "content" }),
      let modifierChild = mirror.children.first(where: { $0.label == "modifier" })
    else {
      // エラーケース：必要なプロパティが見つからない
      return EmptyView._LayoutView()
    }

    // ステップ1: content（元のView）をLayoutViewに変換
    // これがモディファイアの「中身」になる
    let contentView = contentChild.value as? any View ?? EmptyView()
    let contentLayoutView = renderView(contentView)

    // ステップ2: modifierの型を文字列で判定
    // Swiftのジェネリック型情報は実行時に失われるため、
    // 文字列での型名マッチングを使用
    let modifierTypeName = String(describing: type(of: modifierChild.value))

    // 各モディファイアの処理
    // modifierの種類に応じて、適切なラッパーLayoutViewを作成

    if modifierTypeName.contains("PaddingModifier") {
      // .padding() モディファイアの処理
      // パディング（余白）をViewの周囲に追加
      let paddingMirror = Mirror(reflecting: modifierChild.value)

      // edges: パディングを適用する方向（.all, .top, .leadingなど）
      let edges =
        paddingMirror.children.first(where: { $0.label == "edges" })?.value as? Edge.Set ?? .all

      // length: パディングのサイズ（文字数）
      let length = paddingMirror.children.first(where: { $0.label == "length" })?.value as? Int ?? 1

      // 適切なLayoutViewを選択
      if edges == .all {
        // 全方向パディング（デフォルト）
        return PaddingLayoutView(inset: Float(length), child: contentLayoutView)
      } else {
        // 方向指定パディング（.padding(.top, 2)など）
        return DirectionalPaddingLayoutView(
          edges: edges, length: Float(length), child: contentLayoutView)
      }
    } else if modifierTypeName.contains("BorderModifier") {
      // .border() モディファイアの処理
      // Viewの周囲に枠線を描画
      //
      // TUIでのボーダーの実現：
      // - ASCII文字で枠を描画（+, -, |）
      // - Unicodeの罰線文字も使用可能（│, ─, ┌など）
      return CellBorderLayoutView(child: contentLayoutView)
    } else if modifierTypeName.contains("BackgroundModifier") {
      // .background() モディファイアの処理
      // Viewの背景色を設定
      let bgMirror = Mirror(reflecting: modifierChild.value)

      // BackgroundModifierは内部にColor.ColorViewを持つ
      if let bgChild = bgMirror.children.first(where: { $0.label == "background" }),
        let colorView = bgChild.value as? Color.ColorView
      {
        // Color.ColorViewから実際のColorを取得
        let colorMirror = Mirror(reflecting: colorView)
        if let colorChild = colorMirror.children.first(where: { $0.label == "color" }),
          let color = colorChild.value as? Color
        {
          // セルベースの背景色レンダリング
          // 各セルに背景色を設定してANSIエスケープで出力
          return CellBackgroundLayoutView(color: color, child: contentLayoutView)
        }
      }
    } else if modifierTypeName.contains("ForegroundColorModifier") {
      // .foregroundColor() モディファイアの処理
      // テキストの文字色を設定
      let fgMirror = Mirror(reflecting: modifierChild.value)
      if let colorChild = fgMirror.children.first(where: { $0.label == "color" }),
        let color = colorChild.value as? Color
      {
        // ForegroundColorLayoutViewは子Viewの文字色を変更
        // ANSIエスケープシーケンスで色を指定
        return ForegroundColorLayoutView(color: color, child: contentLayoutView)
      }
    } else if modifierTypeName.contains("FrameModifier") {
      // .frame() モディファイアの処理
      // Viewのサイズを固定または制約
      let frameMirror = Mirror(reflecting: modifierChild.value)

      // width: 幅の制約（nilの場合は制約なし）
      let width = frameMirror.children.first(where: { $0.label == "width" })?.value as? Float

      // height: 高さの制約（nilの場合は制約なし）
      let height = frameMirror.children.first(where: { $0.label == "height" })?.value as? Float

      // alignment: フレーム内でのコンテンツの配置
      let alignment =
        frameMirror.children.first(where: { $0.label == "alignment" })?.value as? Alignment
        ?? .center

      return FrameLayoutView(
        width: width, height: height, alignment: alignment, child: contentLayoutView)
    } else if modifierTypeName.contains("AlertModifier") {
      // .alert() モディファイアの処理
      // モーダルなアラートダイアログを表示
      let alertMirror = Mirror(reflecting: modifierChild.value)

      // 必要な情報を取得
      if alertMirror.children.first(where: { $0.label == "_isPresented" }) != nil,
        let titleChild = alertMirror.children.first(where: { $0.label == "title" }),
        let messageChild = alertMirror.children.first(where: { $0.label == "message" }),
        let title = titleChild.value as? String
      {
        let message = messageChild.value as? String

        // AlertModifier型にキャストしてBindingを取得
        // Mirror経由ではBindingの取得が難しいため
        if let alertModifier = modifierChild.value as? AlertModifier {
          return AlertModifierLayoutView(
            content: contentLayoutView,
            isPresented: alertModifier.$isPresented,
            title: title,
            message: message
          )
        }
      }
    }

    // 未対応のモディファイアの場合
    // モディファイアを無視して、元のViewをそのまま返す
    // これにより、未実装のモディファイアでもアプリがクラッシュしない
    return contentLayoutView
  }

  /// ForEachExpandedの変換
  ///
  /// ForEachが展開された後の内部表現を処理します。
  ///
  /// ForEachの仕組み：
  /// 1. ForEach { ... } で配列の各要素からViewを生成
  /// 2. _ForEachExpandedに展開され、全Viewの配列を保持
  /// 3. このメソッドで各ViewをLayoutViewに変換
  ///
  /// 例：
  /// ForEach(items) { item in Text(item.name) }
  /// → [Text("A"), Text("B"), Text("C")...] のように展開される
  ///
  /// - Parameter forEachExpanded: 展開されたForEachの内部表現
  /// - Returns: 複数のViewを含むLayoutView
  private static func renderForEachExpanded(_ forEachExpanded: _ForEachExpandedProtocol)
    -> any LayoutView
  {
    // 各ViewをLayoutViewに変換して配列に格納
    let views = forEachExpanded._views.map { view in
      LegacyAnyView(renderView(view))
    }

    // 結果のView数に応じて適切なLayoutViewを返す
    if views.isEmpty {
      // 空の配列の場合（ForEachのソースが空）
      return EmptyView._LayoutView()
    } else if views.count == 1 {
      // 1つだけの場合は直接返す（最適化）
      return views[0]
    } else {
      // 複数の場合はTupleLayoutViewでラップ
      // VStackやList内で使われることが多い
      return TupleLayoutView(views: views)
    }
  }

  /// ScrollViewの処理
  ///
  /// スクロール可能なコンテナを作成します。
  ///
  /// ScrollViewの特徴：
  /// - 大きなコンテンツを限られた領域で表示
  /// - 矢印キーでスクロール操作
  /// - スクロールバーの表示（オプション）
  /// - 垂直/水平/両方向のスクロール対応
  ///
  /// TUIでの実装上の制約：
  /// - 固定サイズのビューポート（デフォルト: 3行×5文字）
  /// - .frame()モディファイアは現在無視される
  /// - グローバルなスクロール状態の共有（複数ScrollViewの問題）
  ///
  /// - Parameter view: ScrollView型のView
  /// - Returns: ScrollLayoutView
  private static func renderScrollView<V: View>(_ view: V) -> any LayoutView {
    // 型安全なキャストを試みる
    if let scrollView = view as? ScrollView<AnyView> {
      return scrollView._layoutView
    }

    // ジェネリック型の場合はMirrorでプロパティにアクセス
    let mirror = Mirror(reflecting: view)

    // ScrollViewの構成要素を取得
    if let axesChild = mirror.children.first(where: { $0.label == "axes" }),
      let axes = axesChild.value as? Axis.Set,  // スクロール方向
      let showsIndicatorsChild = mirror.children.first(where: { $0.label == "showsIndicators" }),
      let showsIndicators = showsIndicatorsChild.value as? Bool,  // スクロールバー表示
      let contentChild = mirror.children.first(where: { $0.label == "content" }),
      let content = contentChild.value as? any View
    {  // スクロールするコンテンツ

      // コンテンツをLayoutViewに変換
      let contentLayoutView = renderView(content)

      // ScrollLayoutViewを作成
      return ScrollLayoutView(
        axes: axes,  // .vertical, .horizontal, [.vertical, .horizontal]
        showsIndicators: showsIndicators,  // true/false
        child: contentLayoutView
      )
    }

    // エラーケース：必要な情報が取得できない
    return EmptyView._LayoutView()
  }

  /// Listの処理
  ///
  /// リスト形式で項目を表示するViewを作成します。
  ///
  /// Listの特徴：
  /// - 各項目間に自動的にセパレータが挿入される
  /// - ForEachと組み合わせて動的なリストを作成
  /// - VStackと似ているが、リスト用のスタイリングが適用される
  ///
  /// TUIでの実装：
  /// - セパレータはハイフン文字の繰り返しで描画
  /// - 各項目の間に自動的に挿入される
  ///
  /// - Parameter view: List型のView
  /// - Returns: ListLayoutView
  private static func renderList<V: View>(_ view: V) -> any LayoutView {
    // 型安全なキャストを試みる
    if let list = view as? List<AnyView> {
      return list._layoutView
    }

    // ジェネリック型の場合はMirrorでcontentにアクセス
    let mirror = Mirror(reflecting: view)
    if let contentChild = mirror.children.first(where: { $0.label == "content" }),
      let content = contentChild.value as? any View
    {
      // Listのコンテンツ（通常はForEach）をLayoutViewに変換
      let contentLayoutView = renderView(content)

      // ListLayoutViewはコンテンツをラップし、
      // 各項目間にセパレータを挿入する
      return ListLayoutView(child: contentLayoutView)
    }

    // エラーケース：必要な情報が取得できない
    return EmptyView._LayoutView()
  }
}

// ViewにLayoutView変換機能を追加
///
/// このextensionにより、すべてのViewが_layoutViewプロパティを持つようになります。
/// これは内部APIで、ユーザーコードからは直接使用しません。
extension View {
  /// 内部使用：ViewをLayoutViewに変換
  ///
  /// このプロパティは、Viewを実際にターミナルに描画可能な
  /// LayoutViewに変換するためのブリッジです。
  ///
  /// ViewRenderer.renderView()を呼び出し、
  /// Viewの種類に応じた適切なLayoutViewを生成します。
  internal var _layoutView: any LayoutView {
    ViewRenderer.renderView(self)
  }
}

// TupleView用の内部LayoutView
///
/// TupleLayoutViewは、複数のViewをグループ化して保持するLayoutViewです。
///
/// 用途：
/// - ViewBuilderが複数のViewを返す時に使用
/// - ForEachの結果をラップする時に使用
/// - VStackやHStackの子要素を保持
///
/// 注意点：
/// - TupleLayoutView自体は配置を決定しない
/// - 親のVStackやHStackが実際の配置を決定
/// - デフォルトでは縦方向（column）に配置
internal final class TupleLayoutView: LayoutView {
  /// 保持するViewの配列（LegacyAnyViewでラップされた状態）
  let views: [LegacyAnyView]

  /// レイアウト計算後のYogaノード（キャッシュ）
  private var calculatedNode: YogaNode?

  init(views: [LegacyAnyView]) {
    self.views = views
  }

  func makeNode() -> YogaNode {
    // Yogaノードを作成
    let node = YogaNode()

    // デフォルトでは縦方向に配置
    // 実際の配置方向は親（VStack/HStack）が上書きする
    node.flexDirection(.column)

    // 各子ViewのYogaノードを追加
    for view in views {
      node.insert(child: view.makeNode())
    }

    // レイアウト計算のためにノードをキャッシュ
    self.calculatedNode = node
    return node
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    // キャッシュされたノードを使用、なければ新規作成
    let node = calculatedNode ?? makeNode()

    // レイアウト情報がない場合は計算を実行
    // これは通常、親がレイアウト計算を実行していない場合に発生
    if YGNodeLayoutGetWidth(node.rawPtr) == 0 {
      // フォールバック: デフォルト幅で80文字で計算
      node.calculate(width: 80)
    }

    // 各子Viewを計算された位置に描画
    let cnt = Int(YGNodeGetChildCount(node.rawPtr))
    for i in 0..<cnt {
      guard let raw = YGNodeGetChild(node.rawPtr, Int(i)) else { continue }

      // Yogaが計算した子要素の位置を取得
      let dx = Int(YGNodeLayoutGetLeft(raw))  // Xオフセット
      let dy = Int(YGNodeLayoutGetTop(raw))  // Yオフセット

      // 子Viewを適切な位置に描画
      views[i].paint(origin: (origin.x + dx, origin.y + dy), into: &buffer)
    }
  }

  func render(into buffer: inout [String]) {
    // 旧式のレンダリングメソッド（互換性のために保持）
    // 各Viewを順番に文字列バッファにレンダリング
    for view in views {
      view.render(into: &buffer)
    }
  }
}
