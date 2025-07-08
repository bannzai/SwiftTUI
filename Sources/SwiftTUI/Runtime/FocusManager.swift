import Darwin

/// フォーカス管理システム
internal class FocusManager {
    static let shared = FocusManager()
    
    private var focusableViews: [FocusableViewInfo] = []
    private var currentFocusIndex: Int? = nil
    
    private init() {}
    
    /// フォーカス可能なViewの情報
    struct FocusableViewInfo {
        let id: String
        let acceptsInput: Bool
        weak var handler: FocusableView?
    }
    
    /// フォーカス可能なViewを登録
    func register(_ view: FocusableView, id: String, acceptsInput: Bool = false) {
        // 既存の同じIDを削除
        focusableViews.removeAll { $0.id == id }
        
        let info = FocusableViewInfo(id: id, acceptsInput: acceptsInput, handler: view)
        focusableViews.append(info)
        
        // フォーカスを復元または初期設定
        if let focusedID = savedFocusID,
           let newIndex = focusableViews.firstIndex(where: { $0.id == focusedID }) {
            // 以前フォーカスされていたViewが再登録された場合、フォーカスを復元
            currentFocusIndex = newIndex
            updateFocusState()
        } else if currentFocusIndex == nil && !focusableViews.isEmpty {
            // 最初のViewにフォーカスを設定
            currentFocusIndex = 0
            updateFocusState()
        }
    }
    
    /// フォーカス可能なViewを削除
    func unregister(id: String) {
        focusableViews.removeAll { $0.id == id }
        
        // フォーカスインデックスの調整
        if let index = currentFocusIndex, index >= focusableViews.count {
            currentFocusIndex = focusableViews.isEmpty ? nil : focusableViews.count - 1
            updateFocusState()
        }
    }
    
    /// 次のViewにフォーカスを移動
    func focusNext() {
        guard !focusableViews.isEmpty else { return }
        
        if let index = currentFocusIndex {
            currentFocusIndex = (index + 1) % focusableViews.count
        } else {
            currentFocusIndex = 0
        }
        
        updateFocusState()
        CellRenderLoop.scheduleRedraw()
    }
    
    /// 前のViewにフォーカスを移動
    func focusPrevious() {
        guard !focusableViews.isEmpty else { return }
        
        if let index = currentFocusIndex {
            currentFocusIndex = index > 0 ? index - 1 : focusableViews.count - 1
        } else {
            currentFocusIndex = focusableViews.count - 1
        }
        
        updateFocusState()
        CellRenderLoop.scheduleRedraw()
    }
    
    /// 現在フォーカスされているViewのIDを取得
    func currentFocusedID() -> String? {
        guard let index = currentFocusIndex,
              index < focusableViews.count else { return nil }
        return focusableViews[index].id
    }
    
    /// 現在フォーカスされているViewが入力を受け付けるか
    func currentAcceptsInput() -> Bool {
        guard let index = currentFocusIndex,
              index < focusableViews.count else { return false }
        return focusableViews[index].acceptsInput
    }
    
    /// キーボードイベントを処理
    func handleKeyEvent(_ event: KeyboardEvent) -> Bool {
        // Tabでフォーカス移動（Shift+Tabは現在未実装）
        if event.key == .tab {
            focusNext()
            return true
        }
        
        // 現在フォーカスされているViewにイベントを転送
        if let index = currentFocusIndex,
           index < focusableViews.count,
           let handler = focusableViews[index].handler {
            return handler.handleKeyEvent(event)
        }
        
        return false
    }
    
    /// フォーカス状態を更新
    private func updateFocusState() {
        for (index, info) in focusableViews.enumerated() {
            info.handler?.setFocused(index == currentFocusIndex)
        }
    }
    
    /// すべてのフォーカス情報をクリア
    func reset() {
        focusableViews.removeAll()
        currentFocusIndex = nil
    }
    
    private var savedFocusID: String?
    
    /// レンダリング前の準備（現在のフォーカスIDを保持してViewリストをクリア）
    func prepareForRerender() {
        // 現在フォーカスされているViewのIDを保持
        if let index = currentFocusIndex,
           index < focusableViews.count {
            savedFocusID = focusableViews[index].id
        }
        // すべてのViewをクリアするが、フォーカス情報は保持
        focusableViews.removeAll()
        currentFocusIndex = nil
    }
    
    /// デバッグ情報の出力
    func debugPrint() {
        print("[FocusManager] === DEBUG INFO ===")
        print("[FocusManager] Total views: \(focusableViews.count)")
        print("[FocusManager] Current focus index: \(String(describing: currentFocusIndex))")
        for (index, view) in focusableViews.enumerated() {
            print("[FocusManager] [\(index)] \(view.id) - handler: \(view.handler != nil)")
        }
        print("[FocusManager] ==================")
    }
}

/// フォーカス可能なViewのプロトコル
internal protocol FocusableView: AnyObject {
    /// フォーカス状態を設定
    func setFocused(_ focused: Bool)
    
    /// キーボードイベントを処理
    func handleKeyEvent(_ event: KeyboardEvent) -> Bool
}