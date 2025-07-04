import Foundation

// LayoutViewをLegacyViewでラップする構造体
private struct LayoutViewWrapper: LegacyView, LayoutView {
    let layoutView: any LayoutView
    
    func makeNode() -> YogaNode {
        layoutView.makeNode()
    }
    
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        layoutView.paint(origin: origin, into: &buffer)
    }
    
    func render(into buffer: inout [String]) {
        layoutView.render(into: &buffer)
    }
    
    func handle(event: KeyboardEvent) -> Bool {
        // TODO: イベント処理の実装
        return false
    }
}

public extension SwiftTUI {
    /// SwiftUIライクなAPIでアプリケーションを起動
    static func run<Content: View>(_ view: Content) {
        // ViewをLayoutViewに変換
        let layoutView = ViewRenderer.renderView(view)
        
        // 既存のRenderLoopを使用してマウント
        RenderLoop.mount {
            return LegacyAnyView(LayoutViewWrapper(layoutView: layoutView))
        }
        
        // メインループを開始
        dispatchMain()
    }
}