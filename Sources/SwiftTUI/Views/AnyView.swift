/// 型消去されたView
public struct AnyView: View {
    private let _makeLayoutView: () -> any LayoutView
    
    public init<V: View>(_ view: V) {
        // 一時的に内部のLayoutViewに変換する仕組み
        // TODO: ViewをLayoutViewに変換するレンダラーを実装後に更新
        self._makeLayoutView = { 
            // 暫定実装：EmptyViewを返す
            return _EmptyLayoutView()
        }
    }
    
    // AnyView自体はプリミティブViewなのでbodyは持たない
    public typealias Body = Never
}

// 暫定的な空のLayoutView実装
private struct _EmptyLayoutView: LayoutView {
    func makeNode() -> YogaNode { YogaNode() }
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {}
    func render(into buffer: inout [String]) {}
}

// 内部使用：AnyViewをLayoutViewに変換
extension AnyView {
    internal func makeLayoutView() -> any LayoutView {
        _makeLayoutView()
    }
}