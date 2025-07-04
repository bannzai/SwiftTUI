import Foundation

// LayoutViewをLegacyViewでラップする構造体
private struct LayoutViewWrapper: LegacyView {
    let layoutView: any LayoutView
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