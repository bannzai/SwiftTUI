import Foundation

/// Button\u306eLayoutView\u30a4\u30f3\u30b9\u30bf\u30f3\u30b9\u3092\u7ba1\u7406\u3059\u308b\u30de\u30cd\u30fc\u30b8\u30e3\u30fc
internal class ButtonLayoutManager {
    static let shared = ButtonLayoutManager()
    
    private var buttonLayouts: [String: any LayoutView] = [:]
    private var buttonOrder: [String] = [] // 登録順序を保持
    private let queue = DispatchQueue(label: "SwiftTUI.ButtonLayoutManager")
    
    private init() {}
    
    /// ButtonLayoutView\u3092\u53d6\u5f97\u307e\u305f\u306f\u4f5c\u6210
    func getOrCreate<Content: View>(
        id: String,
        action: @escaping () -> Void,
        label: Content
    ) -> any LayoutView {
        return queue.sync {
            if let existing = buttonLayouts[id] {
                fputs("[ButtonLayoutManager] Reusing existing ButtonLayoutView for id: \(id)\n", stderr)
                return existing
            }
            
            fputs("[ButtonLayoutManager] Creating new ButtonLayoutView for id: \(id)\n", stderr)
            let layoutView = ButtonLayoutView(action: action, label: label, id: id)
            buttonLayouts[id] = layoutView
            buttonOrder.append(id)
            return layoutView
        }
    }
    
    /// \u30ec\u30f3\u30c0\u30ea\u30f3\u30b0\u524d\u306e\u6e96\u5099
    func prepareForRerender() {
        // FocusManager\u3068\u540c\u671f\u3057\u3066\u30af\u30ea\u30a2\u3057\u306a\u3044\uff08\u30a4\u30f3\u30b9\u30bf\u30f3\u30b9\u3092\u4fdd\u6301\uff09
        fputs("[ButtonLayoutManager] prepareForRerender called, keeping \(buttonLayouts.count) button layouts\n", stderr)
        
        // 保持しているボタンをFocusManagerに再登録（順序を保持）
        queue.sync {
            for id in buttonOrder {
                if let layoutView = buttonLayouts[id],
                   let buttonLayoutView = layoutView as? FocusableView {
                    fputs("[ButtonLayoutManager] Re-registering button \(id) with FocusManager\n", stderr)
                    FocusManager.shared.register(buttonLayoutView, id: id)
                }
            }
        }
    }
    
    /// \u3059\u3079\u3066\u30af\u30ea\u30a2
    func clear() {
        queue.sync {
            fputs("[ButtonLayoutManager] Clearing \(buttonLayouts.count) button layouts\n", stderr)
            buttonLayouts.removeAll()
            buttonOrder.removeAll()
        }
    }
}