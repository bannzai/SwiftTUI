// PickerTest - Pickerコンポーネントの動作確認
//
// 期待される挙動:
// 1. タイトル "Picker Component Test" が表示される
// 2. 3つのPicker（Color、Size、Language）が表示される
// 3. 各Pickerはラベルと現在の選択値を表示する（例: "Color: Red ▼"）
// 4. Tabキーで次のPickerにフォーカスを移動できる
// 5. Enter/Spaceキーでドロップダウンを開閉できる
// 6. ドロップダウンが開いたら↑/↓キーで選択肢を移動できる
// 7. Enterキーで選択を確定、ESCキーでキャンセルできる
// 8. 初期値: Color=Red, Size=Medium(2), Language=Swift
// 9. 現在の選択値が下部に色付きで表示される
// 10. ESCキー（ドロップダウン閉じ時）でプログラムが終了する
//
// 実行方法: swift run PickerTest

import SwiftTUI

struct PickerTestView: View {
    @State private var selectedColor = "Red"
    @State private var selectedSize = 2
    @State private var selectedLanguage = "Swift"
    
    let colors = ["Red", "Green", "Blue", "Yellow", "Purple"]
    let sizes: [(Int, String)] = [
        (1, "Small"),
        (2, "Medium"),
        (3, "Large"),
        (4, "Extra Large")
    ]
    let languages = ["Swift", "Python", "JavaScript", "Rust", "Go", "Ruby"]
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Picker Component Test")
                .bold()
                .padding()
                .border()
            
            VStack(spacing: 2) {
                Picker("Color", selection: $selectedColor, options: colors)
                    .padding()
                
                Picker("Size", selection: $selectedSize, options: sizes)
                    .padding()
                
                Picker("Language", selection: $selectedLanguage, options: languages)
                    .padding()
            }
            .border()
            .padding()
            
            VStack(spacing: 1) {
                Text("Current Selections:")
                    .bold()
                    .padding(.bottom)
                
                HStack {
                    Text("Color:")
                    Text(selectedColor)
                        .foregroundColor(.cyan)
                }
                
                HStack {
                    Text("Size:")
                    Text(sizes.first(where: { $0.0 == selectedSize })?.1 ?? "Unknown")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Language:")
                    Text(selectedLanguage)
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .border()
            
            Text("Instructions:")
                .foregroundColor(.cyan)
                .padding(.top)
            
            VStack {
                Text("• Tab: Move focus between pickers")
                Text("• Enter/Space: Open/close dropdown")
                Text("• ↑/↓: Navigate options (when open)")
                Text("• Enter: Select option")
                Text("• ESC: Close dropdown / Exit program")
            }
            .foregroundColor(.white)
            .padding()
        }
    }
}

SwiftTUI.run {
    PickerTestView()
}