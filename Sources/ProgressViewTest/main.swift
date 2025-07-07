// ProgressViewTest - ProgressViewコンポーネントの動作確認
//
// 期待される挙動:
// 1. タイトル "ProgressView Component Test" が表示される
// 2. 確定進捗（Determinate）セクションに5つのプログレスバーが表示される
// 3. 各プログレスバーは異なる進捗率（0%, 30%, 75%, 90%, 100%）を表示
// 4. 不確定進捗（Indeterminate）セクションに3つのスピナーが表示される
// 5. スピナーはアニメーション（回転）して表示される
// 6. "Stop Animation"ボタンがあるが、実際には機能しない（タイマー連携未実装）
// 7. 5秒後にプログラムが自動的に終了する
//
// 実行方法: swift run ProgressViewTest

import SwiftTUI
import Foundation

struct ProgressViewTestView: View {
    @State private var progress1: Double = 0.0
    @State private var progress2: Double = 0.3
    @State private var progress3: Double = 0.75
    @State private var isRunning = true
    
    var body: some View {
        VStack(spacing: 2) {
            Text("ProgressView Component Test")
                .bold()
                .padding()
                .border()
            
            VStack(spacing: 2) {
                Text("Determinate Progress:")
                    .bold()
                    .padding(.bottom)
                
                ProgressView(value: progress1, label: "Download")
                    .padding()
                
                ProgressView(value: progress2, label: "Processing")
                    .padding()
                
                ProgressView(value: progress3, label: "Upload")
                    .padding()
                
                ProgressView(value: 0.9, label: "Almost Done")
                    .padding()
                
                ProgressView(value: 1.0, label: "Complete")
                    .padding()
            }
            .border()
            .padding()
            
            VStack(spacing: 2) {
                Text("Indeterminate Progress:")
                    .bold()
                    .padding(.bottom)
                
                ProgressView("Loading...")
                    .padding()
                
                ProgressView("Connecting to server")
                    .padding()
                
                ProgressView()
                    .padding()
            }
            .border()
            .padding()
            
            Text("Progress values will update automatically")
                .foregroundColor(.cyan)
                .padding()
            
            Button("Stop Animation") {
                isRunning.toggle()
            }
            .padding()
        }
    }
}

// 進捗を自動更新するタイマー
var timer: Timer?

func startProgressAnimation() {
    timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        // Note: @Stateの更新はView内でしか行えないため、
        // このデモでは固定値を使用しています。
        // 実際のアプリケーションでは、ViewModelやObservableObjectを使用します。
    }
}

SwiftTUI.run {
    ProgressViewTestView()
}

// 5秒後に自動終了
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    timer?.invalidate()
    CellRenderLoop.shutdown()
}