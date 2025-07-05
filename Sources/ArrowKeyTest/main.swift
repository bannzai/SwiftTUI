import SwiftTUI
import Foundation

struct ArrowKeyTestView: View {
    var body: some View {
        VStack {
            Text("矢印キーテスト")
                .bold()
                .padding()
                .border()
            
            Text("矢印キーを押してください")
                .foregroundColor(.cyan)
            
            Text("最後に押されたキー:")
                .foregroundColor(.yellow)
                .padding()
            
            Text("(ここに表示されます)")
                .foregroundColor(.green)
                .padding()
            
            Text("ESC で終了")
                .foregroundColor(.white)
        }
    }
}

// グローバルキーハンドラーでデバッグ
GlobalKeyHandler.handler = { event in
    let keyName: String
    switch event.key {
    case .up: 
        keyName = "↑ (Up)"
        print("DEBUG: Up arrow key pressed!")
    case .down: 
        keyName = "↓ (Down)"
        print("DEBUG: Down arrow key pressed!")
    case .left: 
        keyName = "← (Left)"
        print("DEBUG: Left arrow key pressed!")
    case .right: 
        keyName = "→ (Right)"
        print("DEBUG: Right arrow key pressed!")
    case .escape: 
        keyName = "ESC"
        print("DEBUG: ESC key pressed!")
    case .tab: 
        keyName = "Tab"
        print("DEBUG: Tab key pressed!")
    case .enter: 
        keyName = "Enter"
        print("DEBUG: Enter key pressed!")
    case .space: 
        keyName = "Space"
        print("DEBUG: Space key pressed!")
    case .character(let c): 
        keyName = "Char: \(c)"
        print("DEBUG: Character key pressed: \(c)")
    default: 
        keyName = "Unknown"
        print("DEBUG: Unknown key pressed!")
    }
    
    // デバッグ用に標準エラーに出力
    fputs("Last key: \(keyName)\n", stderr)
    
    return false  // 他のハンドラーも処理できるようにfalseを返す
}

// 10秒後に自動終了
DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    print("\nExiting...")
    RenderLoop.shutdown()
}

SwiftTUI.run {
    ArrowKeyTestView()
}