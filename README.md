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

# インタラクティブコンポーネントのテスト
swift run SimpleInteractiveTest

# ユーザー登録フォームのデモ
swift run InteractiveFormTest

# SwiftUIライクな完全な例
swift run SwiftUILikeExample

# 高度なコンポーネントのテスト
swift run DirectionalPaddingTest  # 方向指定パディング
swift run SpacingTest             # Stack間隔の指定
swift run ForEachTest             # 動的リスト生成
swift run ScrollViewTest          # スクロール可能なビュー
swift run ListTest                # リスト表示
```

### 現在サポートされているコンポーネント

#### 基本コンポーネント
- **Text**: テキストの表示
- **VStack**: 縦方向のスタックレイアウト（`spacing`パラメータ対応）
- **HStack**: 横方向のスタックレイアウト（`spacing`パラメータ対応）
- **Spacer**: 残りのスペースを埋めるコンポーネント
- **EmptyView**: 何も表示しないビュー

#### インタラクティブコンポーネント
- **TextField**: テキスト入力フィールド
- **Button**: クリック可能なボタン

#### 高度なコンポーネント
- **ForEach**: コレクションから動的にビューを生成
- **ScrollView**: スクロール可能なコンテナ
- **List**: 自動区切り線付きのリスト表示

### ViewModifier

- **`.padding(_:)`**: 内側の余白を追加（全方向）
- **`.padding(.top, _:)`, `.padding(.bottom, _:)`など**: 方向指定の余白
- **`.border()`**: 枠線を描画
- **`.background(_:)`**: 背景色を設定
- **`.foregroundColor(_:)`**: テキスト色を設定
- **`.frame(width:height:)`**: サイズ制約を設定
- **`.bold()`**: 太字テキスト表示

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
            
            Button("Increment") { 
                count += 1 
            }
            
            TextField("Enter message", text: $message)
                .frame(width: 20)
        }
    }
}

// アプリケーションの起動（State対応版）
SwiftTUI.run {
    CounterView()
}
```

#### インタラクティブフォーム

```swift
struct FormView: View {
    @State private var username = ""
    @State private var age = ""
    @State private var submitted = false
    
    var body: some View {
        VStack {
            Text("ユーザー登録")
                .foregroundColor(.cyan)
                .padding()
                .border()
            
            HStack {
                Text("名前:")
                TextField("ユーザー名を入力", text: $username)
                    .frame(width: 20)
            }
            
            HStack {
                Text("年齢:")
                TextField("年齢を入力", text: $age)
                    .frame(width: 10)
            }
            
            Button("送信") {
                submitted = true
            }
            .padding()
            
            if submitted {
                Text("登録完了: \(username) (\(age)歳)")
                    .foregroundColor(.green)
            }
        }
    }
}
```

#### 高度なコンポーネントの使用例

##### ForEach - 動的リスト生成

```swift
struct TodoListView: View {
    let todos = [
        Todo(id: 1, title: "SwiftTUIの実装", done: true),
        Todo(id: 2, title: "テストを書く", done: false),
        Todo(id: 3, title: "ドキュメント作成", done: false)
    ]
    
    var body: some View {
        VStack {
            Text("TODO リスト")
                .bold()
                .padding()
            
            ForEach(todos) { todo in
                HStack {
                    Text(todo.done ? "✓" : "○")
                        .foregroundColor(todo.done ? .green : .red)
                    Text(todo.title)
                }
                .padding()
            }
        }
    }
}
```

##### ScrollView - スクロール可能なコンテンツ

```swift
struct ScrollableView: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(1...50, id: \.self) { i in
                    Text("Item \(i)")
                        .padding()
                        .background(i % 2 == 0 ? .cyan : .magenta)
                }
            }
        }
        .frame(height: 10)  // ビューポートの高さを制限
    }
}
```

##### List - 自動区切り線付きリスト

```swift
struct ListExampleView: View {
    var body: some View {
        List {
            Text("項目1")
                .padding()
            Text("項目2")
                .padding()
            Text("項目3")
                .padding()
        }
        .frame(height: 15)
    }
}
```

##### VStack/HStack with spacing

```swift
struct SpacedLayoutView: View {
    var body: some View {
        VStack(spacing: 2) {  // 各要素間に2行の間隔
            Text("Header")
                .background(.blue)
            
            HStack(spacing: 3) {  // 各要素間に3文字の間隔
                Text("A").background(.red)
                Text("B").background(.green)
                Text("C").background(.yellow)
            }
            
            Text("Footer")
                .background(.cyan)
        }
    }
}
```

### 操作方法

- **Tab / Shift+Tab**: フォーカスの移動
- **Enter / Space**: ボタンのクリック
- **文字入力**: TextFieldへの入力
- **Backspace**: 文字の削除
- **←→**: カーソルの移動（TextField内）
- **↑↓**: ScrollView内でのスクロール
- **ESC**: プログラムの終了
- **Ctrl+C**: 強制終了

### StateTestの動作確認

StateTestでは以下のキー操作が可能です：

```bash
swift run StateTest

# キー操作
u - カウンターを増やす (increment)
d - カウンターを減らす (decrement)  
m - メッセージを切り替える (Hello ⇔ World)
q - プログラムを終了
```

### トラブルシューティング

#### プログラムがすぐに終了してしまう場合

以前のバージョンでは、`swift run` でプログラムを実行するとすぐに終了してしまう問題がありました。
この問題は修正済みですが、もし発生した場合は以下を確認してください：

1. SwiftTUIの最新バージョンを使用していることを確認
2. `SwiftTUI.run()` を使用してアプリケーションを起動していることを確認

#### ビルドエラーが発生する場合

- **ViewBuilder制限**: 1つのViewBuilder内で5つ以上のViewを配置するとエラーになります。この場合はVStackやGroupでグループ化してください。
- **ForEach使用時**: Range（例：`1..<10`）を使用する場合は`ForEachRange`を使用してください。

#### 動作確認済みのサンプル

以下のサンプルは正常に動作することが確認されています：

```bash
# ✅ 基本的なテスト（動作確認済み）
swift run SimpleTest          # シンプルなテキスト表示
swift run SimpleVStackTest    # VStackのテスト
swift run HStackTest          # HStackのテスト
swift run SpacerTest          # Spacerを使ったレイアウト
swift run SimplePaddingTest   # Paddingのテスト

# ✅ State管理（動作確認済み）
swift run StateTest           # @Stateの動作確認（u/d/mキーで値を変更、qで終了）
swift run KeyTestVerify       # グローバルキーハンドラーの動作確認（自動テスト）

# ⚠️ 既知の問題があるサンプル
swift run ListTest            # Range errorが発生する場合があります
swift run ScrollViewTest      # Range errorが発生する場合があります
swift run ForEachTest         # ViewBuilder制限により修正が必要
swift run InteractiveFormTest # ハングする場合があります
```

#### 既知の問題と回避策

1. **Float→Int変換エラー**: Yogaレイアウトエンジンから返される値がNaNやinfiniteの場合があります。これは修正済みです。

2. **Range error**: ForEachやListを使用する際に発生する場合があります。現在調査中です。

3. **ViewBuilder制限**: 1つのブロック内に5つ以上のViewを配置できません。VStackやGroupでグループ化してください。


