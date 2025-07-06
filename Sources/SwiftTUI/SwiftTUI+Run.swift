import Foundation

// グローバルなキーハンドラー
public struct GlobalKeyHandler {
    public static var handler: ((KeyboardEvent) -> Bool)?
}

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
        // グローバルハンドラーを最初にチェック
        if let globalHandler = GlobalKeyHandler.handler, globalHandler(event) {
            RenderLoop.scheduleRedraw()
            return true
        }
        
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
    /// SwiftUIライクなAPIでアプリケーションを起動（セルベースレンダリング）
    static func run<Content: View>(_ view: @escaping () -> Content) {
        // Viewインスタンスを一度だけ作成
        let viewInstance = view()
        
        // セルベースのRenderLoopを使用してマウント
        CellRenderLoop.mount {
            // 保持したインスタンスのLayoutViewを返す
            let layoutView = ViewRenderer.renderView(viewInstance)
            return LegacyAnyView(LayoutViewWrapper(layoutView: layoutView))
        }
        
        // メインループを開始
        RunLoop.main.run()
    }
    
    /// View型を直接受け取るバージョン（後方互換性のため）
    static func run<Content: View>(_ view: Content) {
        // 既にインスタンス化されたViewをそのまま使用
        CellRenderLoop.mount {
            let layoutView = ViewRenderer.renderView(view)
            return LegacyAnyView(LayoutViewWrapper(layoutView: layoutView))
        }
        
        RunLoop.main.run()
    }
}