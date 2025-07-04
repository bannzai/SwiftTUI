import yoga

/// レイアウト計算のコンテキスト
/// RenderLoopから渡される計算済みノードツリーを保持
public final class LayoutContext {
    private var calculatedNodes: [ObjectIdentifier: YogaNode] = [:]
    
    public init() {}
    
    /// 計算済みノードを登録
    public func setCalculatedNode<V: LayoutView>(_ node: YogaNode, for view: V) {
        let id = ObjectIdentifier(type(of: view))
        calculatedNodes[id] = node
    }
    
    /// 計算済みノードを取得
    public func getCalculatedNode<V: LayoutView>(for view: V) -> YogaNode? {
        let id = ObjectIdentifier(type(of: view))
        return calculatedNodes[id]
    }
    
    /// コンテキストをクリア
    public func clear() {
        calculatedNodes.removeAll()
    }
}

/// スレッドローカルなレイアウトコンテキスト
internal var currentLayoutContext: LayoutContext?