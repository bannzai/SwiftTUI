// ToggleTest - Toggleコンポーネントの動作確認
//
// 期待される挙動:
// 1. タイトル "Toggle Component Test" が表示される
// 2. 5つのトグルスイッチが表示される（3つ基本、2つ設定用）
// 3. 各トグルは [x] または [ ] で状態を表示する
// 4. Tabキーでトグル間のフォーカスを移動できる
// 5. Space/Enterキーでフォーカスされたトグルのオン/オフを切り替えられる
// 6. 初期状態: Toggle1=OFF, Toggle2=ON, Toggle3=OFF, Notifications=ON, DarkMode=OFF
// 7. 下部に現在の各トグルの状態（ON/OFF）が色付きで表示される
// 8. ESCキーでプログラムが終了する
//
// 実行方法: swift run ToggleTest

import SwiftTUI

struct ToggleTestView: View {
  @State private var isOn1 = false
  @State private var isOn2 = true
  @State private var isOn3 = false
  @State private var notificationsEnabled = true
  @State private var darkModeEnabled = false

  var body: some View {
    VStack(spacing: 2) {
      Text("Toggle Component Test")
        .bold()
        .padding()
        .border()

      VStack(spacing: 1) {
        Toggle("Simple Toggle", isOn: $isOn1)
          .padding()

        Toggle("Initially On", isOn: $isOn2)
          .padding()

        Toggle("Another Toggle", isOn: $isOn3)
          .padding()
      }
      .border()
      .padding()

      VStack(spacing: 1) {
        Text("Settings")
          .bold()
          .padding(.bottom)

        Toggle("Enable Notifications", isOn: $notificationsEnabled)
        Toggle("Dark Mode", isOn: $darkModeEnabled)
      }
      .padding()
      .border()

      Text("Instructions:")
        .foregroundColor(.cyan)
        .padding(.top)

      VStack {
        Text("• Tab: Move focus between toggles")
        Text("• Space/Enter: Toggle on/off")
        Text("• ESC: Exit program")
      }
      .foregroundColor(.white)
      .padding()

      HStack {
        Text("Values:")
        Text("T1: \(isOn1 ? "ON" : "OFF")")
          .foregroundColor(isOn1 ? .green : .red)
        Text("T2: \(isOn2 ? "ON" : "OFF")")
          .foregroundColor(isOn2 ? .green : .red)
        Text("T3: \(isOn3 ? "ON" : "OFF")")
          .foregroundColor(isOn3 ? .green : .red)
      }
      .padding()
    }
  }
}

SwiftTUI.run {
  ToggleTestView()
}
