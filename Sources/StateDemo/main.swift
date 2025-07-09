// StateDemo - @Stateによる自動的な状態更新のデモ
//
// 期待される挙動:
// 1. "State Demo starting..."が表示される
// 2. カウンターが1秒ごとに自動的にインクリメントされる
// 3. カウンターが5の倍数になるとアクティブ状態がトグルする
// 4. アクティブ状態に応じて文字色と背景色が変化する
// 5. 10秒後に自動的に終了する
//
// 実行方法: swift run StateDemo

import SwiftTUI
import Foundation

print("State Demo starting...")

// タイマーで自動的に状態を変更するデモ
struct StateDemo: View {
    @State private var counter = 0
    @State private var isActive = false
    
    var body: some View {
        VStack {
            Text("Automatic State Updates Demo")
                .foregroundColor(.cyan)
                .padding(2)
                .border()
            
            HStack {
                Text("Counter:")
                    .foregroundColor(.green)
                Text("\(counter)")
                    .foregroundColor(isActive ? .yellow : .red)
                    .padding()
            }
            
            Text(isActive ? "Status: Active" : "Status: Inactive")
                .background(isActive ? .green : .red)
                .padding()
        }
    }
}

// デモ用のビューホルダー
class DemoViewHolder {
    var demo = StateDemo()
    
    func incrementCounter() {
        demo.counter += 1
        if demo.counter % 5 == 0 {
            demo.isActive.toggle()
        }
    }
}

let holder = DemoViewHolder()

// タイマーで自動的に状態を更新
var timer: DispatchSourceTimer?
timer = DispatchSource.makeTimerSource(queue: .main)
timer?.schedule(deadline: .now() + 1, repeating: 1.0)
timer?.setEventHandler {
    holder.incrementCounter()
}
timer?.resume()

// 10秒後に終了
DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    print("\nStopping demo...")
    timer?.cancel()
    RenderLoop.shutdown()
    exit(0)
}

// Viewをクロージャとして渡す
SwiftTUI.run {
    holder.demo
}