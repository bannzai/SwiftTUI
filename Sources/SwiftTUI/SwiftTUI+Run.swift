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
        // FocusManagerに処理を委譲
        if FocusManager.shared.handleKeyEvent(event) {
            RenderLoop.scheduleRedraw()
            return true
        }
        
        // ESCキーで終了
        if event.key == .escape {
            RenderLoop.shutdown()
            return true
        }
        
        return false
    }
}

public extension SwiftTUI {
    /// SwiftUIライクなAPIでアプリケーションを起動
    static func run<Content: View>(_ view: @escaping () -> Content) {
        // 既存のRenderLoopを使用してマウント
        RenderLoop.mount {
            // 毎回新しいViewインスタンスを生成してレンダリング
            let newView = view()
            let layoutView = ViewRenderer.renderView(newView)
            return LegacyAnyView(LayoutViewWrapper(layoutView: layoutView))
        }
        
        // メインループを開始
        RunLoop.main.run()
    }
    
    /// View型を直接受け取るバージョン（後方互換性のため）
    static func run<Content: View>(_ view: Content) {
        run { view }
    }
}