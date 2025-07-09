import Foundation
import yoga
import Darwin

/// セルベースレンダリングをサポートする新しいRenderLoop
public enum CellRenderLoop {
    public static var DEBUG = false
    private static var makeRoot: (() -> LegacyAnyView)?
    private static var cachedRoot: LegacyAnyView?
    private static var cachedLayoutView: (any LayoutView)?
    private static let rq = DispatchQueue(label: "SwiftTUI.CellRender")
    private static var prevCellBuffer: CellBuffer?
    private static var redrawPending = false
    
    public static func mount<V: LegacyView>(_ build: @escaping () -> V) {
        makeRoot = { LegacyAnyView(build()) }
        cachedRoot = makeRoot?()
        // LayoutViewをキャッシュ
        if let root = cachedRoot as? LayoutView {
            cachedLayoutView = root
        }
        fullRedraw()
        startInput()
    }
    
    public static func scheduleRedraw() {
        guard !redrawPending else { return }
        redrawPending = true
        rq.async {
            incrementalRedraw()
            redrawPending = false
        }
    }
    
    // --- frame builder --------------------------------------------------
    private static func buildFrame() -> CellBuffer {
        // レンダリング前にFocusManagerとButtonLayoutManagerを準備
        FocusManager.shared.prepareForRerender()
        ButtonLayoutManager.shared.prepareForRerender()
        
        // 新しいrootを作成して最新の状態を反映
        guard let makeRoot = makeRoot else {
            return CellBuffer(width: 80, height: 24)
        }
        let root = makeRoot()
        cachedRoot = root
        
        // 新しいLayoutViewを作成
        let lv: any LayoutView
        if let layoutView = root as? LayoutView {
            lv = layoutView
            cachedLayoutView = lv
        } else {
            // 従来のレンダリング
            var b: [String] = []
            root.render(into: &b)
            
            // String配列をCellBufferに変換
            var cellBuffer = CellBuffer(width: 80, height: b.count)
            for (row, line) in b.enumerated() {
                bufferWriteCell(row: row, col: 0, text: line, into: &cellBuffer)
            }
            return cellBuffer
        }
        
        // 端末幅取得
        var ws = winsize()
        ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws)
        let width = Float(ws.ws_col > 0 ? ws.ws_col : 80)
        let height = Int(ws.ws_row > 0 ? ws.ws_row : 24)
        
        // Yogaレイアウト計算
        let node = lv.makeNode()
        node.calculate(width: width)
        
        // CellBufferを作成
        var cellBuffer = CellBuffer(width: Int(width), height: height)
        
        // セルベースレンダリング
        if let cellLayoutView = lv as? CellLayoutView {
            cellLayoutView.paintCells(origin: (0, 0), into: &cellBuffer)
        } else {
            // 従来のLayoutViewをアダプター経由で描画
            let adapter = CellLayoutAdapter(lv)
            adapter.paintCells(origin: (0, 0), into: &cellBuffer)
        }
        
        if DEBUG {
            dump(cellBuffer)
        }
        
        // レンダリング完了をFocusManagerに通知
        FocusManager.shared.finishRerendering()
        
        return cellBuffer
    }
    
    // --- draw routines --------------------------------------------------
    private static func fullRedraw() {
        print("\u{1B}[2J\u{1B}[H", terminator: "")
        let cellBuffer = buildFrame()
        let lines = cellBuffer.toANSILines()
        
        for line in lines {
            print(line)
        }
        
        fflush(stdout)
        prevCellBuffer = cellBuffer
    }
    
    private static func incrementalRedraw() {
        let nextBuffer = buildFrame()
        let nextLines = nextBuffer.toANSILines()
        
        if let prevBuffer = prevCellBuffer {
            let prevLines = prevBuffer.toANSILines()
            let common = min(prevLines.count, nextLines.count)
            
            // 差分のある行のみ更新
            for r in 0..<common where prevLines[r] != nextLines[r] {
                mv(r)
                clr()
                print(nextLines[r], terminator: "")
            }
            
            // 新しい行を追加
            if nextLines.count > prevLines.count {
                for r in prevLines.count..<nextLines.count {
                    mv(r)
                    clr()
                    print(nextLines[r], terminator: "")
                }
            } else if nextLines.count < prevLines.count {
                // 余分な行をクリア
                for r in nextLines.count..<prevLines.count {
                    mv(r)
                    clr()
                }
            }
            
            mv(nextLines.count)
        } else {
            // 初回は全描画
            for (index, line) in nextLines.enumerated() {
                mv(index)
                print(line, terminator: "")
            }
        }
        
        fflush(stdout)
        prevCellBuffer = nextBuffer
    }
    
    // --- helpers --------------------------------------------------------
    private static func mv(_ r: Int) {
        print("\u{1B}[\(r + 1);1H", terminator: "")
    }
    
    private static func clr() {
        print("\u{1B}[2K", terminator: "")
    }
    
    private static func startInput() {
        InputLoop.start { ev in
            cachedRoot?.handle(event: ev)
        }
    }
    
    // DEBUG
    private static func dump(_ buffer: CellBuffer) {
        print("---- CellBuffer Debug ----")
        let lines = buffer.toANSILines()
        for (index, line) in lines.enumerated() {
            print("\(index): [\(line)]")
        }
        print("-------------------------")
    }
    
    public static func shutdown() {
        InputLoop.stop()
        if let buffer = prevCellBuffer {
            mv(buffer.toANSILines().count)
        }
        clr()
        fflush(stdout)
        exit(0)
    }
}