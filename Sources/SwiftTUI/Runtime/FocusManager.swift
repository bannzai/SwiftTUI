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
        
        // 最初のViewにフォーカスを設定
        if currentFocusIndex == nil && !focusableViews.isEmpty {
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
        RenderLoop.scheduleRedraw()
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
        RenderLoop.scheduleRedraw()
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
        // Tab/Shift+Tabでフォーカス移動
        if event.key == .tab {
            if event.shift {
                focusPrevious()
            } else {
                focusNext()
            }
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
}

/// フォーカス可能なViewのプロトコル
internal protocol FocusableView: AnyObject {
    /// フォーカス状態を設定
    func setFocused(_ focused: Bool)
    
    /// キーボードイベントを処理
    func handleKeyEvent(_ event: KeyboardEvent) -> Bool
}