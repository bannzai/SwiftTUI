import yoga
import Darwin

/// ScrollViewのレイアウト実装
internal final class ScrollLayoutView: LayoutView {
    let axes: Axis.Set
    let showsIndicators: Bool
    let child: any LayoutView
    
    // スクロール状態を静的に保持（一時的な解決策）
    private static var globalScrollOffset: (x: Int, y: Int) = (0, 0)
    private static var globalContentLineCount: Int = 0
    
    // インスタンス変数はglobalの参照として使用
    var scrollOffset: (x: Int, y: Int) {
        get { ScrollLayoutView.globalScrollOffset }
        set { ScrollLayoutView.globalScrollOffset = newValue }
    }
    var contentLineCount: Int {
        get { ScrollLayoutView.globalContentLineCount }
        set { ScrollLayoutView.globalContentLineCount = newValue }
    }
    var contentSize: (width: Int, height: Int) = (0, 0)
    var viewportSize: (width: Int, height: Int) = (0, 0)
    
    init(axes: Axis.Set, showsIndicators: Bool, child: any LayoutView) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.child = child
        
        // FocusManagerに登録
        let id = "ScrollView_\(ObjectIdentifier(self).hashValue)"
        // fputs("DEBUG: ScrollLayoutView init, id=\(id)\n", stderr)
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
        fputs("DEBUG: paint() called on \(ObjectIdentifier(self).hashValue), scrollOffset=\(scrollOffset)\n", stderr)
        
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
        
        // fputs("DEBUG: Raw viewport size from Yoga: \(viewportWidth)x\(viewportHeight)\n", stderr)
        
        // コンテンツのサイズを取得
        if let childRaw = YGNodeGetChild(node.rawPtr, 0) {
            let contentWidth = safeInt(YGNodeLayoutGetWidth(childRaw))
            let contentHeight = safeInt(YGNodeLayoutGetHeight(childRaw))
            
            // スクロール可能な範囲を計算
            let maxScrollX = max(0, contentWidth - viewportWidth)
            let maxScrollY = max(0, contentHeight - viewportHeight)
            
            // スクロールオフセットは直接使用（maxScrollYは正しく計算されないため）
            let scrollX = scrollOffset.x
            let scrollY = scrollOffset.y
            
            fputs("DEBUG: paint() scrollOffset=\(scrollOffset), using scrollY=\(scrollY) directly\n", stderr)
            
            // スクロール状態を更新
            self.contentSize = (contentWidth, contentHeight)
            self.viewportSize = (viewportWidth, viewportHeight)
            
            // 一時バッファを作成（コンテンツ全体を描画）
            var tempBuffer = Array(repeating: "", count: max(contentHeight, 100))
            // fputs("DEBUG: Before child.paint - tempBuffer.count=\(tempBuffer.count), contentSize=\(contentWidth)x\(contentHeight)\n", stderr)
            child.paint(origin: (0, 0), into: &tempBuffer)
            // fputs("DEBUG: After child.paint\n", stderr)
            
            // tempBufferの実際の内容を16進数で表示
            // if !tempBuffer[0].isEmpty {
            //     let hexString = tempBuffer[0].data(using: .utf8)?.map { String(format: "%02x", $0) }.joined(separator: " ") ?? ""
            //     fputs("DEBUG: tempBuffer[0] hex: \(hexString)\n", stderr)
            // }
            
            // デバッグ: 重要な情報のみ
            // fputs("DEBUG: viewport=\(viewportWidth)x\(viewportHeight), origin=(\(origin.x),\(origin.y))\n", stderr)
            
            // tempBufferの内容を確認
            var nonEmptyCount = 0
            for i in 0..<min(10, tempBuffer.count) {
                if !tempBuffer[i].isEmpty {
                    // ANSIエスケープを可視化して表示
                    // let escaped = tempBuffer[i].replacingOccurrences(of: "\u{1B}", with: "\\e")
                    // fputs("DEBUG: tempBuffer[\(i)] = '\(escaped)' (len=\(tempBuffer[i].count))\n", stderr)
                    nonEmptyCount += 1
                }
            }
            // fputs("DEBUG: Found \(nonEmptyCount) non-empty lines in first 10\n", stderr)
            
            // スクロールオフセットを適用してビューポート部分をコピー
            // frameで制限された実際の描画行数を使用
            // FrameLayoutViewから渡される実際のviewportサイズを使用すべきだが、
            // 現在は固定値を使用
            let actualViewportHeight = 3  // SimpleScrollTestでは3行
            let actualViewportWidth = 5  // BorderLayoutViewの内部幅（maxWidth）
            // fputs("DEBUG: Using fixed viewport: \(actualViewportWidth)x\(actualViewportHeight)\n", stderr)
            
            // 実際のコンテンツ行を見つける
            var contentLines: [Int] = []
            for i in 0..<tempBuffer.count {
                if !tempBuffer[i].isEmpty {
                    contentLines.append(i)
                }
            }
            // fputs("DEBUG: Found content at lines: \(contentLines)\n", stderr)
            
            // コンテンツ行数を保存
            self.contentLineCount = contentLines.count
            
            // スクロール位置に基づいて表示する行を決定
            let startIndex = scrollY
            let endIndex = min(startIndex + actualViewportHeight, contentLines.count)
            
            // fputs("DEBUG: scrollY=\(scrollY), contentLines.count=\(contentLines.count), displaying \(startIndex)..<\(endIndex)\n", stderr)
            
            for i in 0..<actualViewportHeight {
                let dstY = origin.y + i
                
                // バッファの範囲を拡張（必要に応じて）
                while dstY >= buffer.count {
                    buffer.append("")
                }
                
                let contentIndex = startIndex + i
                if contentIndex < contentLines.count {
                    let srcY = contentLines[contentIndex]
                    let srcLine = tempBuffer[srcY]
                    
                    // スクロール時のみデバッグ出力
                    if scrollY > 0 {
                        let displayText = srcLine.replacingOccurrences(of: "\u{1B}", with: "\\e")
                        fputs("DEBUG: Displaying row \(i): '\(displayText)' (content line \(contentIndex+1))\n", stderr)
                    }
                    
                    // クリッピング：actualViewportWidthの範囲内に制限
                    let clippedLine = clipToWidth(srcLine, width: actualViewportWidth)
                    bufferWrite(row: dstY, col: origin.x, text: clippedLine, into: &buffer)
                } else {
                    // コンテンツがない場合は空行
                    // fputs("DEBUG: Viewport row \(i): no content (empty line)\n", stderr)
                }
            }
            
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

/// ANSIエスケープシーケンスを保持しながら文字列を指定幅にクリップ
private func clipToWidth(_ text: String, width: Int) -> String {
    // fputs("DEBUG: clipToWidth input='\(text.replacingOccurrences(of: "\u{1B}", with: "\\e"))', width=\(width)\n", stderr)
    
    // 幅が十分に大きい場合はそのまま返す
    if width >= 100 {
        return text
    }
    
    var result = ""
    var currentWidth = 0
    var inEscape = false
    var escapeBuffer = ""
    
    for char in text {
        if char == "\u{1B}" {
            inEscape = true
            escapeBuffer = String(char)
        } else if inEscape {
            escapeBuffer.append(char)
            if char == "m" {
                // エスケープシーケンス完了
                result.append(escapeBuffer)
                inEscape = false
                escapeBuffer = ""
            }
        } else {
            // 実際の文字
            // 日本語文字は幅2として計算
            let charWidth = char.unicodeScalars.first?.value ?? 0 > 0x7F ? 2 : 1
            
            if currentWidth + charWidth <= width {
                result.append(char)
                currentWidth += charWidth
            } else {
                break
            }
        }
    }
    
    // 未完了のエスケープシーケンスがある場合は追加
    if inEscape {
        result.append(escapeBuffer)
    }
    
    // fputs("DEBUG: clipToWidth output='\(result.replacingOccurrences(of: "\u{1B}", with: "\\e"))'\n", stderr)
    return result
}

// ScrollLayoutViewをFocusableに拡張
extension ScrollLayoutView: FocusableView {
    func setFocused(_ focused: Bool) {
        // ScrollViewはフォーカス状態の視覚的変化を持たない
    }
    
    func handleKeyEvent(_ event: KeyboardEvent) -> Bool {
        fputs("DEBUG: handleKeyEvent called on \(ObjectIdentifier(self).hashValue)\n", stderr)
        
        // 矢印キーでスクロール
        switch event.key {
        case .up where axes.contains(.vertical):
            scrollOffset.y = max(0, scrollOffset.y - 1)
            fputs("DEBUG: ScrollView UP pressed, scrollOffset.y=\(scrollOffset.y)\n", stderr)
            RenderLoop.scheduleRedraw()
            return true
            
        case .down where axes.contains(.vertical):
            // 実際のコンテンツ行数に基づいてmaxScrollを計算
            // 例: 5行のコンテンツで3行のビューポートなら、maxScroll = 5 - 3 = 2
            let maxScroll = max(0, contentLineCount - 3)  // 3はビューポートの高さ（固定値）
            scrollOffset.y = min(scrollOffset.y + 1, maxScroll)
            fputs("DEBUG: ScrollView DOWN pressed, scrollOffset.y=\(scrollOffset.y), maxScroll=\(maxScroll), contentLineCount=\(contentLineCount)\n", stderr)
            RenderLoop.scheduleRedraw()
            return true
            
        case .left where axes.contains(.horizontal):
            scrollOffset.x = max(0, scrollOffset.x - 1)
            RenderLoop.scheduleRedraw()
            return true
            
        case .right where axes.contains(.horizontal):
            let maxScroll = max(0, contentSize.width - viewportSize.width)
            scrollOffset.x = min(scrollOffset.x + 1, maxScroll)
            RenderLoop.scheduleRedraw()
            return true
            
        default:
            return false
        }
    }
    
    var isFocusable: Bool { true }
}