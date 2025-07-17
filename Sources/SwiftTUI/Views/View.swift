/// SwiftTUIのViewプロトコル
///
/// このファイルは、SwiftTUIの最も基本的な概念である「View」を定義します。
/// SwiftUIと同じく、UIの見た目と振る舞いを宣言的に記述するための基盤です。
///
/// SwiftUIとの関係：
/// - SwiftUIのViewプロトコルと同じ構造
/// - 宣言的UI：「どう見えるか」を記述し、「どう描画するか」はフレームワークが処理
/// - コンポジション：小さなViewを組み合わせて複雑なUIを構築
///
/// 基本的な使い方：
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         Text("Hello, SwiftTUI!")
///     }
/// }
/// ```

/// SwiftUIライクなViewプロトコル
///
/// すべてのUIコンポーネントが準拠すべき基本プロトコルです。
/// このプロトコルにより、SwiftTUIはViewの階層構造を理解し、
/// 適切にレンダリングすることができます。
public protocol View {
  /// Viewの本体となるコンテンツの型
  ///
  /// associatedtypeとは：
  /// - プロトコルで使用する「後で決まる型」のプレースホルダー
  /// - 各Viewが独自のBody型を持つことができる
  /// - 例：TextのBodyはNever、VStackのBodyはTupleView<...>など
  ///
  /// Body: View という制約により、bodyは必ず別のViewを返す必要がある
  associatedtype Body: View

  /// Viewの宣言的な定義
  ///
  /// このプロパティで、Viewがどのように見えるかを定義します。
  ///
  /// @ViewBuilderとは：
  /// - 複数のViewを返せるようにする特殊な属性
  /// - if文やForEachなどの制御構文を使える
  /// - SwiftUIと同じ書き心地を実現
  ///
  /// 例：
  /// ```swift
  /// var body: some View {
  ///     if isLoggedIn {
  ///         WelcomeView()
  ///     } else {
  ///         LoginView()
  ///     }
  /// }
  /// ```
  @ViewBuilder var body: Body { get }
}

/// プリミティブView（葉ノード）のためのデフォルト実装
///
/// プリミティブViewとは：
/// - Text、Image、Spacerなど、他のViewを含まない基本的なView
/// - これらはbodyを持たない（自分自身が最終的なコンテンツ）
/// - Body型をNeverにすることで、bodyが呼ばれないことを保証
///
/// where Body == Never：
/// - 「BodyがNever型の場合にのみ」この実装を使用
/// - Neverは「値を持たない型」で、実際には呼ばれないことを示す
extension View where Body == Never {
  public var body: Never {
    // このメソッドは実際には呼ばれない
    // プリミティブViewは内部で直接レンダリングされる
    fatalError("View must have a body")
  }
}

/// Never型をViewプロトコルに適合させる
///
/// なぜNeverをViewにする必要があるか：
/// - プリミティブViewのBody型としてNeverを使用
/// - Body: Viewという制約を満たすため、NeverもViewである必要がある
/// - 型システムの整合性を保つための技術的な実装
///
/// これにより、以下のような定義が可能になる：
/// ```swift
/// struct Text: View {
///     typealias Body = Never  // TextはプリミティブViewなのでbodyを持たない
/// }
/// ```
extension Never: View {
  public typealias Body = Never
}
