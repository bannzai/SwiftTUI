// SliderTest - Sliderコンポーネントの動作確認
//
// 期待される挙動:
// 1. タイトル "Slider Component Test" が表示される
// 2. 5つのスライダーが2つのセクションに分かれて表示される
// 3. Audio Settings セクション: Volume (0-1), Brightness (0-1), Playback Speed (0.5-2.0)
// 4. Environment セクション: Temperature (-10-40), Progress (0-100)
// 5. 各スライダーはトラック上にサム（つまみ）が表示される
// 6. Tabキーでスライダー間のフォーカスを移動できる
// 7. ←/→キーで値を調整できる（細かいステップ）
// 8. Home/Endキーで最小値/最大値にジャンプできる
// 9. 初期値: Volume=0.5, Brightness=0.7, Speed=1.0, Temperature=20.0, Progress=0.0
// 10. 下部に現在の各スライダーの値がリアルタイムで表示される
// 11. ESCキーでプログラムが終了する
//
// 実行方法: swift run SliderTest

import SwiftTUI

struct SliderTestView: View {
    @State private var volume: Double = 0.5
    @State private var brightness: Double = 0.7
    @State private var speed: Double = 1.0
    @State private var temperature: Double = 20.0
    @State private var progress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Slider Component Test")
                .bold()
                .padding()
                .border()
            
            VStack(spacing: 2) {
                Text("Audio Settings")
                    .bold()
                    .padding(.bottom)
                
                Slider(value: $volume, in: 0...1, label: "Volume")
                    .padding()
                
                Slider(value: $brightness, in: 0...1, label: "Brightness")
                    .padding()
                
                Slider(value: $speed, in: 0.5...2.0, label: "Playback Speed")
                    .padding()
            }
            .border()
            .padding()
            
            VStack(spacing: 2) {
                Text("Environment")
                    .bold()
                    .padding(.bottom)
                
                Slider(value: $temperature, in: -10...40, label: "Temperature")
                    .padding()
                
                Slider(value: $progress, in: 0...100, label: "Progress")
                    .padding()
            }
            .border()
            .padding()
            
            Text("Instructions:")
                .foregroundColor(.cyan)
                .padding(.top)
            
            VStack {
                Text("• Tab: Move focus between sliders")
                Text("• ←/→: Adjust value")
                Text("• Home/End: Jump to min/max")
                Text("• ESC: Exit program")
            }
            .foregroundColor(.white)
            .padding()
            
            VStack(spacing: 1) {
                Text("Current Values:")
                    .bold()
                HStack {
                    Text("Volume: \(String(format: "%.2f", volume))")
                    Text("Brightness: \(String(format: "%.2f", brightness))")
                }
                HStack {
                    Text("Speed: \(String(format: "%.2f", speed))x")
                    Text("Temp: \(String(format: "%.1f", temperature))°C")
                }
            }
            .padding()
            .foregroundColor(.yellow)
        }
    }
}

SwiftTUI.run {
    SliderTestView()
}