/// SwiftUIライクなViewプロトコル
public protocol View {
    /// Viewの本体となるコンテンツ
    associatedtype Body: View
    
    /// Viewの宣言的な定義
    @ViewBuilder var body: Body { get }
}

// デフォルト実装：Viewが自身をbodyとして返す場合
public extension View where Body == Never {
    var body: Never {
        fatalError("View must have a body")
    }
}

// Never型をViewに適合させる（プリミティブViewの終端として使用）
extension Never: View {
    public typealias Body = Never
}