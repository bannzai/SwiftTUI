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
        fputs("[FocusManager] Registering view: \(id)\n", stderr)
        
        // 既存の同じIDを削除
        focusableViews.removeAll { $0.id == id }
        
        let info = FocusableViewInfo(id: id, acceptsInput: acceptsInput, handler: view)
        focusableViews.append(info)
        fputs("[FocusManager] Total focusable views: \(focusableViews.count)\n", stderr)
        
        // フォーカスを復元または初期設定
        if let focusedID = savedFocusID,
           let newIndex = focusableViews.firstIndex(where: { $0.id == focusedID }) {
            // 以前フォーカスされていたViewが再登録された場合、フォーカスを復元
            currentFocusIndex = newIndex
            updateFocusState()
            fputs("[FocusManager] Restored focus to: \(focusedID)\n", stderr)
        } else if currentFocusIndex == nil && !focusableViews.isEmpty {
            // 最初のViewにフォーカスを設定
            currentFocusIndex = 0
            updateFocusState()
            fputs("[FocusManager] Set initial focus to first view\n", stderr)
        }
    }
    
    /// フォーカス可能なViewを削除
    func unregister(id: String) {
        fputs("[FocusManager] Unregistering view: \(id)\n", stderr)
        focusableViews.removeAll { $0.id == id }
        fputs("[FocusManager] Remaining focusable views: \(focusableViews.count)\n", stderr)
        
        // フォーカスインデックスの調整
        if let index = currentFocusIndex, index >= focusableViews.count {
            currentFocusIndex = focusableViews.isEmpty ? nil : focusableViews.count - 1
            updateFocusState()
        }
    }
    
    /// 次のViewにフォーカスを移動
    func focusNext() {
        fputs("[FocusManager] focusNext called\n", stderr)
        guard !focusableViews.isEmpty else { 
            fputs("[FocusManager] No focusable views\n", stderr)
            return 
        }
        
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
        fputs("[FocusManager] handleKeyEvent called with key: \(event.key)\n", stderr)
        fputs("[FocusManager] Current focusable views count: \(focusableViews.count)\n", stderr)
        fputs("[FocusManager] Current focus index: \(String(describing: currentFocusIndex))\n", stderr)
        
        // Tabでフォーカス移動（Shift+Tabは現在未実装）
        if event.key == .tab {
            fputs("[FocusManager] Tab key detected\n", stderr)
            debugPrint()
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
        fputs("[FocusManager] updateFocusState: currentFocusIndex=\(String(describing: currentFocusIndex))\n", stderr)
        for (index, info) in focusableViews.enumerated() {
            let isFocused = (index == currentFocusIndex)
            fputs("[FocusManager] Setting focus for \(info.id): \(isFocused)\n", stderr)
            info.handler?.setFocused(isFocused)
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
        fputs("[FocusManager] prepareForRerender called, current views: \(focusableViews.count)\n", stderr)
        // 現在フォーカスされているViewのIDを保持
        if let index = currentFocusIndex,
           index < focusableViews.count {
            savedFocusID = focusableViews[index].id
            fputs("[FocusManager] Saving focus ID: \(savedFocusID ?? "nil")\n", stderr)
        }
        // すべてのViewをクリアするが、フォーカス情報は保持
        focusableViews.removeAll()
        currentFocusIndex = nil
        fputs("[FocusManager] prepareForRerender finished, views cleared\n", stderr)
    }
    
    /// デバッグ情報の出力
    func debugPrint() {
        fputs("[FocusManager] === DEBUG INFO ===\n", stderr)
        fputs("[FocusManager] Total views: \(focusableViews.count)\n", stderr)
        fputs("[FocusManager] Current focus index: \(String(describing: currentFocusIndex))\n", stderr)
        for (index, view) in focusableViews.enumerated() {
            fputs("[FocusManager] [\(index)] \(view.id) - handler: \(view.handler != nil)\n", stderr)
        }
        fputs("[FocusManager] ==================\n", stderr)
    }
}

/// フォーカス可能なViewのプロトコル
internal protocol FocusableView: AnyObject {
    /// フォーカス状態を設定
    func setFocused(_ focused: Bool)
    
    /// キーボードイベントを処理
    func handleKeyEvent(_ event: KeyboardEvent) -> Bool
}