# SwiftTUI

React Ink のように TUI を宣言的UIでかけるライブラリを作りたいです。言語はSwiftで、ライブラリ名はSwiftTUIにします。SwiftPMで配布します。SwiftUIのシンタックスでTUIが作れるようにします。

必須であるコンポーネント(例: Text,VStack,TextField, BackgroundModifier)等はバージョン0.0.1 でサポートしたい。不要なコンポーネントやViewModifier(LazyVStack,GroupedBox,Form,.containerRelative()...)などはサポートしません。要はSwiftUIにあるものの中からコンポーネントは基本的に決まりますが、全てをサポートするわけではないです

## 使い方

### 基本的な使用例

```swift
import SwiftTUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, SwiftTUI!")
            Text("This is a terminal UI framework")
        }
    }
}

// アプリケーションのエントリーポイント
@main
struct MyApp {
    static func main() {
        SwiftTUI.run(ContentView())
    }
}
```

### 動作確認方法

プロジェクトには複数のサンプルが含まれています：

```bash
# シンプルなテキスト表示
swift run SimpleTest

# VStackのテスト（縦方向のレイアウト）
swift run SimpleVStackTest

# HStackのテスト（横方向のレイアウト）
swift run HStackTest

# ネストされたレイアウトのテスト
swift run NestedLayoutTest

# Spacerを使ったレイアウト
swift run SpacerTest

# ViewModifierのテスト
swift run SimplePaddingTest

# State管理のテスト
swift run SimpleStateTest

# SwiftUIライクな完全な例
swift run SwiftUILikeExample
```

### 現在サポートされているコンポーネント

- **Text**: テキストの表示
- **VStack**: 縦方向のスタックレイアウト
- **HStack**: 横方向のスタックレイアウト
- **Spacer**: 残りのスペースを埋めるコンポーネント
- **EmptyView**: 何も表示しないビュー

### ViewModifier

- **`.padding(_:)`**: 内側の余白を追加
- **`.border()`**: 枠線を描画
- **`.background(_:)`**: 背景色を設定
- **`.foregroundColor(_:)`**: テキスト色を設定

### State管理

- **`@State`**: 値の変更を監視し、自動的に再レンダリング
- **`@Binding`**: 親Viewから渡された値への参照
- **`Binding.constant(_:)`**: 読み取り専用のBinding

### コード例

#### VStackとHStackの組み合わせ

```swift
struct NestedView: View {
    var body: some View {
        VStack {
            Text("Header")
            HStack {
                Text("Left")
                VStack {
                    Text("Top")
                    Text("Bottom")
                }
                Text("Right")
            }
            Text("Footer")
        }
    }
}
```

#### Spacerを使ったレイアウト

```swift
struct SpacedView: View {
    var body: some View {
        HStack {
            Text("Left aligned")
            Spacer()
            Text("Right aligned")
        }
    }
}
```

#### ViewModifierの使用例

```swift
struct StyledView: View {
    var body: some View {
        VStack {
            Text("Styled Text")
                .foregroundColor(.red)
                .padding(2)
                .border()
            
            Text("Background Color")
                .background(.blue)
            
            Text("Combined Modifiers")
                .foregroundColor(.green)
                .background(.yellow)
                .padding()
        }
    }
}
```

#### @Stateを使った動的UI

```swift
struct CounterView: View {
    @State private var count = 0
    @State private var message = "Hello"
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
                .padding()
                .border()
            
            Text("Message: \(message)")
                .foregroundColor(.cyan)
            
            // TextFieldやButtonが実装されたら:
            // Button("Increment") { count += 1 }
            // TextField("Enter message", text: $message)
        }
    }
}

// アプリケーションの起動（State対応版）
SwiftTUI.run {
    CounterView()
}
```


