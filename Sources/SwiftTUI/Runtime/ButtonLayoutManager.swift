import Foundation
import Darwin

/// Button\u306eLayoutView\u30a4\u30f3\u30b9\u30bf\u30f3\u30b9\u3092\u7ba1\u7406\u3059\u308b\u30de\u30cd\u30fc\u30b8\u30e3\u30fc
internal class ButtonLayoutManager {
    static let shared = ButtonLayoutManager()
    
    // FocusableViewとして保持するように変更
    private var buttonLayouts: [String: (any LayoutView & FocusableView)] = [:]
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
                return existing
            }
            
            let layoutView = ButtonLayoutView(action: action, label: label, id: id)
            buttonLayouts[id] = layoutView
            buttonOrder.append(id)
            return layoutView
        }
    }
    
    /// \u30ec\u30f3\u30c0\u30ea\u30f3\u30b0\u524d\u306e\u6e96\u5099
    func prepareForRerender() {
        queue.sync {
            // \u3059\u3079\u3066\u306eButtonLayoutView\u306e\u30d5\u30a9\u30fc\u30ab\u30b9\u72b6\u614b\u3092\u30ea\u30bb\u30c3\u30c8
            for (_, layoutView) in buttonLayouts {
                layoutView.setFocused(false)
            }
        }
    }
    
    /// \u3059\u3079\u3066\u30af\u30ea\u30a2
    func clear() {
        queue.sync {
            buttonLayouts.removeAll()
            buttonOrder.removeAll()
        }
    }
}