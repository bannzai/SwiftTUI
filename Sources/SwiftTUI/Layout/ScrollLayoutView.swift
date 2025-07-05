import yoga

/// ScrollViewのレイアウト実装
internal final class ScrollLayoutView: LayoutView {
    let axes: Axis.Set
    let showsIndicators: Bool
    let child: any LayoutView
    
    // スクロール状態
    var scrollOffset: (x: Int, y: Int) = (0, 0)
    var contentSize: (width: Int, height: Int) = (0, 0)
    var viewportSize: (width: Int, height: Int) = (0, 0)
    
    init(axes: Axis.Set, showsIndicators: Bool, child: any LayoutView) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.child = child
        
        // FocusManagerに登録
        let id = "ScrollView_\(ObjectIdentifier(self).hashValue)"
        FocusManager.shared.register(self, id: id, acceptsInput: false)
    }
    
    deinit {
        // FocusManagerから削除
        let id = "ScrollView_\(ObjectIdentifier(self).hashValue)"
        FocusManager.shared.unregister(id: id)
    }
    
    func makeNode() -> YogaNode {
        let node = YogaNode()
        
        // ScrollViewは親のサイズに合わせる
        node.setFlexGrow(1.0)
        node.setFlexShrink(1.0)
        
        // オーバーフローを許可
        // TODO: Yogaでオーバーフロー設定が必要な場合
        
        let childNode = child.makeNode()
        node.insert(child: childNode)
        
        return node
    }
    
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        let node = makeNode()
        
        // レイアウトを計算（デフォルトサイズを使用）
        let defaultWidth: Float = 80
        let defaultHeight: Float = 24
        node.calculate(width: defaultWidth, height: defaultHeight)
        
        // 安全なFloat→Int変換関数
        func safeInt(_ v: Float) -> Int {
            v.isFinite ? Int(v) : 0
        }
        
        // ビューポートのサイズを取得
        let viewportWidth = safeInt(YGNodeLayoutGetWidth(node.rawPtr))
        let viewportHeight = safeInt(YGNodeLayoutGetHeight(node.rawPtr))
        
        // コンテンツのサイズを取得
        if let childRaw = YGNodeGetChild(node.rawPtr, 0) {
            let contentWidth = safeInt(YGNodeLayoutGetWidth(childRaw))
            let contentHeight = safeInt(YGNodeLayoutGetHeight(childRaw))
            
            // スクロール可能な範囲を計算
            let maxScrollX = max(0, contentWidth - viewportWidth)
            let maxScrollY = max(0, contentHeight - viewportHeight)
            
            // スクロールオフセットを制限
            let scrollX = min(max(0, scrollOffset.x), maxScrollX)
            let scrollY = min(max(0, scrollOffset.y), maxScrollY)
            
            // コンテンツを描画（スクロールオフセットを適用）
            child.paint(
                origin: (origin.x - scrollX, origin.y - scrollY),
                into: &buffer
            )
            
            // スクロールインジケーターを描画
            if showsIndicators {
                paintScrollIndicators(
                    origin: origin,
                    viewportSize: (viewportWidth, viewportHeight),
                    contentSize: (contentWidth, contentHeight),
                    scrollOffset: (scrollX, scrollY),
                    into: &buffer
                )
            }
        }
    }
    
    func render(into buffer: inout [String]) {
        child.render(into: &buffer)
    }
    
    // スクロールインジケーターの描画
    private func paintScrollIndicators(
        origin: (x: Int, y: Int),
        viewportSize: (width: Int, height: Int),
        contentSize: (width: Int, height: Int),
        scrollOffset: (x: Int, y: Int),
        into buffer: inout [String]
    ) {
        // 垂直スクロールバー
        if axes.contains(.vertical) && contentSize.height > viewportSize.height {
            let scrollbarHeight = max(1, viewportSize.height * viewportSize.height / contentSize.height)
            let scrollbarY = scrollOffset.y * (viewportSize.height - scrollbarHeight) / (contentSize.height - viewportSize.height)
            
            // 右端にスクロールバーを描画
            let scrollbarX = origin.x + viewportSize.width - 1
            for y in 0..<viewportSize.height {
                let row = origin.y + y
                if row >= 0 && row < buffer.count {
                    let isThumb = y >= scrollbarY && y < scrollbarY + scrollbarHeight
                    let char = isThumb ? "█" : "│"
                    let color = isThumb ? "\u{1B}[37m" : "\u{1B}[90m"  // White for thumb, dark gray for track
                    bufferWrite(
                        row: row,
                        col: scrollbarX,
                        text: color + char + "\u{1B}[0m",
                        into: &buffer
                    )
                }
            }
        }
        
        // 水平スクロールバー
        if axes.contains(.horizontal) && contentSize.width > viewportSize.width {
            let scrollbarWidth = max(1, viewportSize.width * viewportSize.width / contentSize.width)
            let scrollbarX = scrollOffset.x * (viewportSize.width - scrollbarWidth) / (contentSize.width - viewportSize.width)
            
            // 下端にスクロールバーを描画
            let scrollbarY = origin.y + viewportSize.height - 1
            if scrollbarY >= 0 && scrollbarY < buffer.count {
                for x in 0..<viewportSize.width {
                    let col = origin.x + x
                    let isThumb = x >= scrollbarX && x < scrollbarX + scrollbarWidth
                    let char = isThumb ? "█" : "─"
                    let color = isThumb ? "\u{1B}[37m" : "\u{1B}[90m"  // White for thumb, dark gray for track
                    bufferWrite(
                        row: scrollbarY,
                        col: col,
                        text: color + char + "\u{1B}[0m",
                        into: &buffer
                    )
                }
            }
        }
    }
}

// ScrollLayoutViewをFocusableに拡張
extension ScrollLayoutView: FocusableView {
    func setFocused(_ focused: Bool) {
        // ScrollViewはフォーカス状態の視覚的変化を持たない
    }
    
    func handleKeyEvent(_ event: KeyboardEvent) -> Bool {
        // 矢印キーでスクロール
        switch event.key {
        case .up where axes.contains(.vertical):
            scrollOffset.y = max(0, scrollOffset.y - 1)
            return true
            
        case .down where axes.contains(.vertical):
            scrollOffset.y += 1
            return true
            
        case .left where axes.contains(.horizontal):
            scrollOffset.x = max(0, scrollOffset.x - 1)
            return true
            
        case .right where axes.contains(.horizontal):
            scrollOffset.x += 1
            return true
            
        default:
            return false
        }
    }
    
    var isFocusable: Bool { true }
}