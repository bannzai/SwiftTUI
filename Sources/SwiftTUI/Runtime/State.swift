/// State：SwiftTUIの状態管理の基本
///
/// このファイルは、SwiftUIと同じ@Stateプロパティラッパーを実装しています。
/// @Stateは、Viewが持つ内部状態を管理し、値が変更されると自動的に
/// UIを再レンダリングする仕組みを提供します。
///
/// 使用例：
/// ```swift
/// struct CounterView: View {
///     @State private var count = 0
///
///     var body: some View {
///         VStack {
///             Text("Count: \(count)")
///             Button("Increment") {
///                 count += 1  // 自動的に再レンダリング！
///             }
///         }
///     }
/// }
/// ```

/// @Stateプロパティラッパー
///
/// プロパティラッパーとは：
/// - プロパティの振る舞いをカスタマイズする機能
/// - @を付けて使用（例：@State）
/// - getter/setterに独自のロジックを追加できる
@propertyWrapper
public struct State<Value> {
  /// 内部でミュータブルな値を保持するためのボックスクラス
  ///
  /// なぜクラス（参照型）を使うのか：
  /// - Stateは構造体（値型）だが、内部の値は変更可能である必要がある
  /// - 構造体のプロパティを変更するにはmutatingが必要
  /// - しかし、View内では構造体をmutatingできない
  /// - そこで、内部にクラス（参照型）を持ち、その中の値を変更する
  ///
  /// この設計により、Stateインスタンス自体は不変でも、
  /// 内部の値は変更可能になる
  final class Box {
    var value: Value
    init(_ value: Value) { self.value = value }
  }

  /// 値を保持するボックス（参照型）
  private let box: Box

  /// 初期化メソッド
  ///
  /// @State var count = 0 と書いたとき、
  /// wrappedValue（0）がこのinitに渡される
  public init(wrappedValue value: Value) {
    self.box = Box(value)
  }

  /// プロパティラッパーの実際の値
  ///
  /// このプロパティにより、@Stateで宣言した変数に
  /// 通常のプロパティのようにアクセスできる
  public var wrappedValue: Value {
    get { box.value }

    /// nonmutating set の意味：
    /// - 通常、構造体のプロパティを変更するsetterはmutatingが必要
    /// - しかし、ここではboxの中身を変更するだけなので、
    ///   State自体は変更されない
    /// - そのため、nonmutatingを使える
    nonmutating set {
      box.value = newValue

      /// ここが重要！値が変更されたら自動的に再レンダリング
      /// これにより、UIが自動的に更新される
      CellRenderLoop.scheduleRedraw()
    }
  }

  /// $演算子でアクセスできるBinding
  ///
  /// projectedValueにより、$countのように$を付けて
  /// Bindingを取得できる
  ///
  /// 使用例：
  /// TextField("Name", text: $name)  // $nameはBinding<String>
  public var projectedValue: Binding<Value> {
    Binding(
      get: { self.wrappedValue },
      set: { self.wrappedValue = $0 }
    )
  }
}

/// SwiftUIライクなBindingプロパティラッパー
///
/// Bindingとは：
/// - 値への双方向の参照
/// - 親Viewと子View間でデータを共有するための仕組み
/// - 値の取得（get）と設定（set）の両方をカプセル化
///
/// @Stateとの違い：
/// - @State: 値の所有者（データのソース）
/// - @Binding: 値への参照（データへのリンク）
///
/// 使用例：
/// ```swift
/// struct ParentView: View {
///     @State private var text = ""
///
///     var body: some View {
///         ChildView(text: $text)  // $でBindingを渡す
///     }
/// }
///
/// struct ChildView: View {
///     @Binding var text: String  // 親のStateを参照
///
///     var body: some View {
///         TextField("Enter text", text: $text)
///     }
/// }
/// ```
@propertyWrapper
public struct Binding<Value> {
  /// 値を取得するためのクロージャ
  private let getter: () -> Value

  /// 値を設定するためのクロージャ
  private let setter: (Value) -> Void

  /// カスタムBinding を作成
  ///
  /// @escapingの意味：
  /// - クロージャが初期化後も保持される
  /// - インスタンスのライフサイクルを超えて使用される
  public init(get: @escaping () -> Value, set: @escaping (Value) -> Void) {
    self.getter = get
    self.setter = set
  }

  /// Bindingの実際の値
  ///
  /// getterとsetterを通じて値にアクセス
  /// これにより、値の変更が元のソース（@Stateなど）に反映される
  public var wrappedValue: Value {
    get { getter() }

    /// nonmutating set：
    /// - Binding自体は変更されない（getter/setterは同じ）
    /// - setterクロージャを呼ぶだけ
    nonmutating set { setter(newValue) }
  }

  /// $演算子でアクセスした場合、自分自身を返す
  ///
  /// これにより、@Bindingプロパティに対しても
  /// $を使ってさらに子Viewに渡せる
  public var projectedValue: Binding<Value> {
    self
  }
}

/// Bindingの便利メソッド
extension Binding {
  /// 固定値のBinding（読み取り専用）
  ///
  /// 用途：
  /// - プレビューやテストで使用
  /// - 読み取り専用のデータを渡す場合
  /// - 一時的に編集を無効化したい場合
  ///
  /// 使用例：
  /// ```swift
  /// // プレビューで固定値を使用
  /// struct MyView_Previews: PreviewProvider {
  ///     static var previews: some View {
  ///         MyView(text: .constant("固定テキスト"))
  ///     }
  /// }
  /// ```
  ///
  /// 注意：setterは何もしないので、値を変更しても反映されない
  public static func constant(_ value: Value) -> Binding<Value> {
    Binding(
      get: { value },  // 常に同じ値を返す
      set: { _ in }  // 何もしない（値の変更を無視）
    )
  }
}
