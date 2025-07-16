# SwiftTUI詳細編 - Yogaレイアウトエンジン、セルレンダリング、プロセス管理の深層

## はじめに

この詳細編では、SwiftTUIの最も複雑な部分に踏み込みます。Yogaレイアウトエンジンの統合、セルベースレンダリングの詳細実装、そしてプロセス管理とターミナル制御について、実装レベルで理解していきます。

## 1. Yogaレイアウトエンジンの統合

### 1.1 Yogaとは

Yoga（旧称：css-layout）は、Facebook（現Meta）が開発したFlexboxレイアウトエンジンです。Web標準のFlexboxアルゴリズムをC++で実装し、様々なプラットフォームで使用できます。

```
Flexboxの概念：
┌─────────────────────────────┐
│ Container (flex-direction)   │
│ ┌─────┐ ┌─────┐ ┌─────┐   │
│ │Item1│ │Item2│ │Item3│   │
│ └─────┘ └─────┘ └─────┘   │
└─────────────────────────────┘
```

### 1.2 YogaNodeの作成と設定

SwiftTUIでは、各ViewがYogaNodeを作成します：

```swift
// LayoutView.swift
protocol LayoutView {
    func makeNode() -> YogaNode
    func paint(at position: CGPoint, to buffer: inout CellBuffer)
}

// VStackの実装例
struct VStackLayoutView: LayoutView {
    let children: [LayoutView]
    let spacing: Int
    
    func makeNode() -> YogaNode {
        let node = YogaNode()
        
        // Flexboxプロパティの設定
        node.flexDirection = .column      // 縦方向
        node.justifyContent = .flexStart  // 上寄せ
        node.alignItems = .stretch       // 子要素を横いっぱいに
        
        // 子ノードを追加
        for (index, child) in children.enumerated() {
            let childNode = child.makeNode()
            
            // spacing の実装
            if index > 0 && spacing > 0 {
                childNode.marginTop = Float(spacing)
            }
            
            node.addChild(childNode)
        }
        
        return node
    }
}
```

### 1.3 レイアウト計算の流れ

```swift
// レイアウト計算のプロセス
func calculateLayout(rootView: LayoutView, screenSize: CGSize) {
    // 1. Yogaノードツリーを構築
    let rootNode = rootView.makeNode()
    
    // 2. ルートノードのサイズを設定
    rootNode.width = Float(screenSize.width)
    rootNode.height = Float(screenSize.height)
    
    // 3. Yogaにレイアウト計算を実行させる
    rootNode.calculateLayout(
        width: Float(screenSize.width),
        height: Float(screenSize.height),
        direction: .LTR  // Left-To-Right
    )
    
    // 4. 計算結果を取得
    let layout = rootNode.layout
    print("位置: (\(layout.left), \(layout.top))")
    print("サイズ: \(layout.width) x \(layout.height)")
}
```

### 1.4 Spacerの実装

Spacerは、Flexboxの`flex-grow`プロパティを使用して実装されます：

```swift
struct SpacerLayoutView: LayoutView {
    func makeNode() -> YogaNode {
        let node = YogaNode()
        
        // flex-grow: 1 で余白を埋める
        node.flexGrow = 1.0
        
        // 最小サイズは0
        node.minWidth = 0
        node.minHeight = 0
        
        return node
    }
    
    func paint(at position: CGPoint, to buffer: inout CellBuffer) {
        // Spacerは何も描画しない
    }
}

// 使用例：
// VStack {
//     Text("上")
//     Spacer()  // ← この部分が伸びる
//     Text("下")
// }
```

### 1.5 Frameモディファイアの実装

```swift
struct FrameLayoutView: LayoutView {
    let content: LayoutView
    let width: Int?
    let height: Int?
    
    func makeNode() -> YogaNode {
        let node = content.makeNode()
        
        // 幅の制約
        if let width = width {
            node.width = Float(width)
        }
        
        // 高さの制約
        if let height = height {
            node.height = Float(height)
        }
        
        return node
    }
}
```

## 2. セルベースレンダリングの詳細

### 2.1 Cell構造体の設計

```swift
// Cell.swift
struct Cell: Equatable {
    var character: Character = " "
    var foregroundColor: Color = .default
    var backgroundColor: Color = .default
    var style: Style = []
    
    // スタイルフラグ
    struct Style: OptionSet {
        let rawValue: UInt8
        
        static let bold = Style(rawValue: 1 << 0)
        static let italic = Style(rawValue: 1 << 1)
        static let underline = Style(rawValue: 1 << 2)
        static let blink = Style(rawValue: 1 << 3)
    }
}
```

### 2.2 CellBufferの実装

```swift
// CellBuffer.swift
class CellBuffer {
    private var cells: [[Cell]]
    let width: Int
    let height: Int
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.cells = Array(
            repeating: Array(repeating: Cell(), count: width),
            count: height
        )
    }
    
    // セルへのアクセス
    subscript(x: Int, y: Int) -> Cell {
        get {
            guard x >= 0 && x < width && y >= 0 && y < height else {
                return Cell()  // 範囲外は空のセル
            }
            return cells[y][x]
        }
        set {
            guard x >= 0 && x < width && y >= 0 && y < height else {
                return  // 範囲外は無視
            }
            cells[y][x] = newValue
        }
    }
    
    // 文字列の書き込み
    func write(_ text: String, at position: CGPoint, 
               foreground: Color = .default,
               background: Color = .default,
               style: Cell.Style = []) {
        var x = Int(position.x)
        let y = Int(position.y)
        
        for char in text {
            if char == "\n" {
                // 改行処理
                continue
            }
            
            self[x, y] = Cell(
                character: char,
                foregroundColor: foreground,
                backgroundColor: background,
                style: style
            )
            x += 1
        }
    }
}
```

### 2.3 背景色の処理

背景色は特別な処理が必要です：

```swift
// CellBackgroundLayoutView.swift
struct CellBackgroundLayoutView: CellLayoutView {
    let content: LayoutView
    let color: Color
    
    func render(at position: CGPoint, to buffer: inout CellBuffer) {
        // 1. まず子要素を一時バッファにレンダリング
        var tempBuffer = CellBuffer(width: buffer.width, height: buffer.height)
        content.paint(at: position, to: &tempBuffer)
        
        // 2. 実際にコンテンツが描画された範囲を検出
        let bounds = detectContentBounds(in: tempBuffer)
        
        // 3. その範囲全体に背景色を適用
        for y in bounds.minY...bounds.maxY {
            for x in bounds.minX...bounds.maxX {
                var cell = tempBuffer[x, y]
                cell.backgroundColor = color
                buffer[x, y] = cell
            }
        }
    }
    
    private func detectContentBounds(in buffer: CellBuffer) -> (minX: Int, minY: Int, maxX: Int, maxY: Int) {
        var minX = Int.max, minY = Int.max
        var maxX = Int.min, maxY = Int.min
        
        for y in 0..<buffer.height {
            for x in 0..<buffer.width {
                if buffer[x, y].character != " " {
                    minX = min(minX, x)
                    minY = min(minY, y)
                    maxX = max(maxX, x)
                    maxY = max(maxY, y)
                }
            }
        }
        
        return (minX, minY, maxX, maxY)
    }
}
```

### 2.4 ボーダーの描画

```swift
// CellBorderLayoutView.swift
struct CellBorderLayoutView: CellLayoutView {
    let content: LayoutView
    
    // ボーダー文字（Unicode Box Drawing）
    let topLeft = "┌"
    let topRight = "┐"
    let bottomLeft = "└"
    let bottomRight = "┘"
    let horizontal = "─"
    let vertical = "│"
    
    func render(at position: CGPoint, to buffer: inout CellBuffer) {
        // 1. コンテンツのサイズを計算
        let contentBounds = calculateContentBounds()
        
        // 2. ボーダーを含めた全体サイズ
        let borderWidth = contentBounds.width + 2
        let borderHeight = contentBounds.height + 2
        
        // 3. ボーダーを描画
        // 上辺
        buffer.write(topLeft, at: CGPoint(x: position.x, y: position.y))
        for x in 1..<borderWidth-1 {
            buffer.write(horizontal, at: CGPoint(x: position.x + x, y: position.y))
        }
        buffer.write(topRight, at: CGPoint(x: position.x + borderWidth - 1, y: position.y))
        
        // 左右の辺
        for y in 1..<borderHeight-1 {
            buffer.write(vertical, at: CGPoint(x: position.x, y: position.y + y))
            buffer.write(vertical, at: CGPoint(x: position.x + borderWidth - 1, y: position.y + y))
        }
        
        // 下辺
        buffer.write(bottomLeft, at: CGPoint(x: position.x, y: position.y + borderHeight - 1))
        for x in 1..<borderWidth-1 {
            buffer.write(horizontal, at: CGPoint(x: position.x + x, y: position.y + borderHeight - 1))
        }
        buffer.write(bottomRight, at: CGPoint(x: position.x + borderWidth - 1, y: position.y + borderHeight - 1))
        
        // 4. コンテンツを中に描画
        content.paint(at: CGPoint(x: position.x + 1, y: position.y + 1), to: &buffer)
    }
}
```

## 3. プロセス管理とターミナル制御

### 3.1 ターミナルモードの管理

```swift
// TerminalManager.swift
class TerminalManager {
    private var originalTermios: termios?
    
    func enterRawMode() {
        // 1. 現在の設定を保存
        var termios = termios()
        tcgetattr(STDIN_FILENO, &termios)
        originalTermios = termios
        
        // 2. Raw modeの設定
        // ICANON: 行単位の入力を無効化（1文字ずつ読む）
        // ECHO: 入力文字のエコーバックを無効化
        // ISIG: Ctrl+C等のシグナル生成を無効化
        termios.c_lflag &= ~(UInt(ICANON) | UInt(ECHO) | UInt(ISIG))
        
        // 3. 入力の最小文字数と待ち時間
        termios.c_cc[Int(VMIN)] = 1   // 最低1文字
        termios.c_cc[Int(VTIME)] = 0  // 待ち時間なし
        
        // 4. 設定を適用
        tcsetattr(STDIN_FILENO, TCSANOW, &termios)
        
        // 5. 画面をクリア
        print("\u{001B}[2J")     // 画面全体をクリア
        print("\u{001B}[H")      // カーソルをホームポジションへ
        
        // 6. カーソルを非表示
        print("\u{001B}[?25l")
    }
    
    func exitRawMode() {
        // 1. カーソルを表示
        print("\u{001B}[?25h")
        
        // 2. 元の設定を復元
        if let originalTermios = originalTermios {
            tcsetattr(STDIN_FILENO, TCSANOW, &originalTermios)
        }
        
        // 3. 画面をクリア
        print("\u{001B}[2J")
        print("\u{001B}[H")
    }
}
```

### 3.2 シグナルハンドリング

```swift
// SignalHandler.swift
class SignalHandler {
    static func setup() {
        // 1. SIGINT (Ctrl+C) のハンドリング
        signal(SIGINT) { _ in
            // グレースフルシャットダウン
            TerminalManager.shared.exitRawMode()
            exit(0)
        }
        
        // 2. SIGWINCH (ウィンドウサイズ変更) のハンドリング
        signal(SIGWINCH) { _ in
            // 新しいサイズを取得
            var winsize = winsize()
            if ioctl(STDOUT_FILENO, TIOCGWINSZ, &winsize) == 0 {
                let newWidth = Int(winsize.ws_col)
                let newHeight = Int(winsize.ws_row)
                
                // リサイズイベントを発火
                NotificationCenter.default.post(
                    name: .terminalDidResize,
                    object: nil,
                    userInfo: ["width": newWidth, "height": newHeight]
                )
            }
        }
    }
}
```

### 3.3 メインループの実装

```swift
// SwiftTUI+Run.swift
public class SwiftTUI {
    private static var rootView: (any View)?
    private static var renderLoop: CellRenderLoop?
    private static var inputLoop: InputLoop?
    
    public static func run<V: View>(_ view: V) {
        // 1. 初期化
        rootView = view
        TerminalManager.shared.enterRawMode()
        SignalHandler.setup()
        
        // 2. レンダリングループを開始
        renderLoop = CellRenderLoop(rootView: view)
        renderLoop?.start()
        
        // 3. 入力ループを開始
        inputLoop = InputLoop()
        inputLoop?.start()
        
        // 4. メインRunLoopを実行
        // これによりプログラムが終了せずに動き続ける
        RunLoop.main.run()
    }
}
```

### 3.4 ディスパッチとイベント処理

```swift
// EventDispatcher.swift
class EventDispatcher {
    typealias EventHandler = (KeyboardEvent) -> Void
    private var handlers: [ObjectIdentifier: EventHandler] = [:]
    
    func register(for view: AnyObject, handler: @escaping EventHandler) {
        let id = ObjectIdentifier(view)
        handlers[id] = handler
    }
    
    func dispatch(_ event: KeyboardEvent) {
        // 1. フォーカスされているViewを特定
        if let focusedView = FocusManager.shared.focusedView {
            let id = ObjectIdentifier(focusedView)
            
            // 2. そのViewのハンドラを呼び出す
            if let handler = handlers[id] {
                handler(event)
                return
            }
        }
        
        // 3. グローバルハンドラ（例：Ctrl+C）
        switch event {
        case .ctrlC:
            // アプリケーション終了
            TerminalManager.shared.exitRawMode()
            exit(0)
        default:
            break
        }
    }
}
```

## 4. 高度なテクニック

### 4.1 ダブルバッファリング

画面のちらつきを防ぐため、ダブルバッファリングを実装：

```swift
class DoubleBufferedRenderer {
    private var frontBuffer: CellBuffer
    private var backBuffer: CellBuffer
    
    func render(view: LayoutView) {
        // 1. バックバッファに描画
        view.render(to: &backBuffer)
        
        // 2. 差分のみを画面に反映
        for y in 0..<height {
            for x in 0..<width {
                if frontBuffer[x, y] != backBuffer[x, y] {
                    updateCell(at: (x, y), with: backBuffer[x, y])
                }
            }
        }
        
        // 3. バッファを入れ替え
        swap(&frontBuffer, &backBuffer)
    }
}
```

### 4.2 非同期レンダリング

重い処理をブロックしないための非同期レンダリング：

```swift
class AsyncRenderer {
    private let renderQueue = DispatchQueue(label: "render", qos: .userInteractive)
    private let semaphore = DispatchSemaphore(value: 1)
    
    func scheduleRender() {
        renderQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 同時に複数のレンダリングが走らないように
            self.semaphore.wait()
            defer { self.semaphore.signal() }
            
            // メインスレッドでView階層を読み取り
            let viewSnapshot = DispatchQueue.main.sync {
                self.captureViewHierarchy()
            }
            
            // バックグラウンドでレンダリング計算
            let buffer = self.renderToBuffer(viewSnapshot)
            
            // メインスレッドで画面更新
            DispatchQueue.main.async {
                self.updateScreen(with: buffer)
            }
        }
    }
}
```

### 4.3 メモリ効率化

大きな画面でのメモリ使用量を最適化：

```swift
// スパースバッファの実装
class SparseBuffer {
    private var cells: [Position: Cell] = [:]
    private let defaultCell = Cell()
    
    subscript(x: Int, y: Int) -> Cell {
        get {
            let pos = Position(x: x, y: y)
            return cells[pos] ?? defaultCell
        }
        set {
            let pos = Position(x: x, y: y)
            if newValue == defaultCell {
                // デフォルト値なら削除してメモリ節約
                cells.removeValue(forKey: pos)
            } else {
                cells[pos] = newValue
            }
        }
    }
}
```

## 5. トラブルシューティング

### 5.1 デバッグログの実装

```swift
// Logger.swift
class Logger {
    private let logFile: FileHandle?
    
    init() {
        // ログファイルを開く（標準エラー出力を使用）
        logFile = FileHandle.standardError
    }
    
    func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(
            from: Date(),
            dateStyle: .none,
            timeStyle: .medium
        )
        let logMessage = "[\(timestamp)] \(message)\n"
        
        if let data = logMessage.data(using: .utf8) {
            logFile?.write(data)
        }
    }
}

// 使用例：
// logger.log("レンダリング開始: \(view)")
```

### 5.2 パフォーマンスプロファイリング

```swift
class PerformanceProfiler {
    private var timings: [String: TimeInterval] = [:]
    
    func measure<T>(_ name: String, block: () throws -> T) rethrows -> T {
        let start = CACurrentMediaTime()
        defer {
            let elapsed = CACurrentMediaTime() - start
            timings[name] = elapsed
            
            if elapsed > 0.016 { // 60FPS = 16ms
                logger.log("⚠️ Slow operation: \(name) took \(elapsed * 1000)ms")
            }
        }
        
        return try block()
    }
}
```

## まとめ

詳細編では、SwiftTUIの最も複雑な3つの要素について深く掘り下げました：

1. **Yogaレイアウトエンジン**：Flexboxアルゴリズムによる柔軟なレイアウト計算
2. **セルベースレンダリング**：各文字位置を個別に管理する精密な描画システム
3. **プロセス管理**：ターミナルのraw mode制御とイベント処理

これらの技術により、SwiftTUIはSwiftUIの宣言的なAPIをターミナル環境で実現しています。

今後の開発では、これらの知識を基に：
- 新しいコンポーネントの実装
- パフォーマンスの最適化
- より高度な機能の追加

などに取り組むことができるでしょう。SwiftTUIプロジェクトへの貢献をお待ちしています！