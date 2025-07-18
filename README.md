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

#### TUI初心者向けドキュメント

SwiftTUIの仕組みを理解するための3段階のドキュメントが用意されています：

1. **入門編** (`SwiftTUI-Beginner.md`)
   - TUIとは何か、SwiftTUIの基本概念
   - セルという概念と画面更新の仕組み

2. **中級編** (`SwiftTUI-Intermediate.md`)
   - レンダリングシステムの詳細（CellRenderLoop、差分更新）
   - イベント処理とフォーカス管理
   - @State、@Binding、Observableによる状態管理

3. **詳細編** (`SwiftTUI-Advanced.md`)
   - Yogaレイアウトエンジンの統合
   - セルベースレンダリングの実装詳細
   - ターミナルのraw mode制御とプロセス管理

4. **C API詳細ガイド** (`C-API-Guide.md`)
   - SwiftTUIで使用されているC由来のAPI、Darwin API、tty関連のシステムコール
   - termios、ioctl、winsize、signal、atexit、read、fputs、fflush、exitの詳細解説
   - 各APIの代替案と選択理由
   - ファイルディスクリプタとターミナル制御の基礎知識

これらのドキュメントは、TUIやシェル、プロセスの知識を段階的に学びながら、SwiftTUIがどのようにSwiftUIのような宣言的インタフェースをターミナル上で実現しているかを理解できるよう構成されています。

#### ソースコードのコメントを読む

SwiftTUIのソースコードには、TUI初心者向けの詳細なコメントが追加されています。以下の順序で読むことをお勧めします：

**Phase 1: 基本的なコンポーネント（完了済み）**
1. `Sources/SwiftTUI/Views/Text.swift` - 基本的なテキスト表示
2. `Sources/SwiftTUI/Views/VStack.swift` / `HStack.swift` - レイアウトコンテナ
3. `Sources/SwiftTUI/Views/Spacer.swift` - 余白の管理
4. `Sources/SwiftTUI/Views/TextField.swift` - テキスト入力
5. `Sources/SwiftTUI/Views/Button.swift` - インタラクティブボタン

**Phase 2: レンダリングシステム（詳細コメント追加済み）**
1. `Sources/SwiftTUI/Rendering/ViewRenderer.swift` - ViewからLayoutViewへの変換
2. `Sources/SwiftTUI/Layout/LayoutView.swift` - レイアウトプロトコル
3. `Sources/SwiftTUI/Layout/CellLayoutView.swift` - セルベース描画
4. `Sources/SwiftTUI/Runtime/Cell.swift` - セル管理の核心

**Phase 3: インタラクティブ機能（詳細コメント追加済み）**
1. `Sources/SwiftTUI/Input/InputLoop.swift` - キーボード入力処理
2. `Sources/SwiftTUI/Input/Keyboard.swift` - キーイベント定義
3. `Sources/SwiftTUI/Runtime/FocusManager.swift` - フォーカス管理

各ファイルには以下の情報が含まれています：
- TUI初心者向けの概念説明
- 技術用語の解説（raw mode、ESCシーケンスなど）
- 処理の流れをステップバイステップで説明
- 実装の特徴や注意点

#### サンプルプログラム

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

# 新しいコンポーネントのテスト
swift run ToggleTest              # On/Offスイッチ
swift run PickerTest              # ドロップダウン選択
swift run ProgressViewTest        # 進捗表示（5秒後に自動終了）
swift run SliderTest              # 値選択スライダー
swift run AlertTest               # 警告ダイアログ

# TextFieldの枠線表示確認
swift run InteractiveFormTest     # 枠線なしのTextFieldを使ったフォーム
cd Examples/DemoForLT && swift run # .border()付きTextFieldのフォーム

# Observable/状態管理のテスト
swift run ObservableModelTest     # SwiftTUI Observableと@Environmentの動作確認
swift run SimpleObservableTest    # シンプルなSwiftTUI Observableパターンのテスト
swift run StandardObservableTest  # Swift標準@Observableマクロのテスト（Swift 5.9+）
```

#### コード品質の確認

今回のリファクタリングでは、すべてのSwiftファイルがSwiftの標準的なコーディングスタイルに従うよう修正されました。以下のコマンドで、主要なサンプルが正常に動作することを確認できます：

```bash
# 基本的な動作確認
swift run SimpleTest           # 修正されたLegacyTextの動作確認
swift run SimplePaddingTest    # 修正されたPaddingの動作確認
swift run ModifierTest         # 修正されたBorderの動作確認

# 複雑なレイアウトの動作確認
swift run SwiftUILikeExample   # 総合的な動作確認
swift run InteractiveFormTest  # インタラクティブコンポーネントの動作確認
```

### 現在サポートされているコンポーネント

#### 基本コンポーネント
- **Text**: テキストの表示
- **VStack**: 縦方向のスタックレイアウト（`spacing`、`alignment`パラメータ対応）
- **HStack**: 横方向のスタックレイアウト（`spacing`、`alignment`パラメータ対応）
- **Spacer**: 残りのスペースを埋めるコンポーネント
- **EmptyView**: 何も表示しないビュー

#### インタラクティブコンポーネント
- **TextField**: テキスト入力フィールド（枠線なし、`.border()`モディファイアで装飾可能）
- **Button**: クリック可能なボタン

#### 高度なコンポーネント
- **ForEach**: コレクションから動的にビューを生成
- **ScrollView**: スクロール可能なコンテナ
- **List**: 自動区切り線付きのリスト表示
- **Toggle**: On/Offを切り替えるスイッチ
- **Picker**: ドロップダウン形式の選択コンポーネント
- **ProgressView**: 進捗状況の表示（確定/不確定）
- **Slider**: 範囲内の値を選択するスライダー
- **Alert**: 警告ダイアログの表示

### ViewModifier

- **`.padding(_:)`**: 内側の余白を追加（全方向）
- **`.padding(.top, _:)`, `.padding(.bottom, _:)`など**: 方向指定の余白
- **`.border()`**: 枠線を描画
- **`.background(_:)`**: 背景色を設定
- **`.foregroundColor(_:)`**: テキスト色を設定
- **`.frame(width:height:)`**: サイズ制約を設定
- **`.bold()`**: 太字テキスト表示
- **`.alert(_:isPresented:message:)`**: アラートダイアログを表示

### State管理

- **`@State`**: 値の変更を監視し、自動的に再レンダリング
- **`@Binding`**: 親Viewから渡された値への参照
- **`Binding.constant(_:)`**: 読み取り専用のBinding

#### Observableシステム（WWDC23スタイル）
- **`Observable`**: 変更通知をサポートするプロトコル
- **`notifyChange()`**: 手動で変更を通知するメソッド

#### 環境値
- **`@Environment`**: View階層を通じて伝播される値
- **`EnvironmentValues`**: 環境値のコンテナ
- **`.environment()`**: 環境値を設定するモディファイア
- **`.disabled()`**: isEnabled環境値を設定

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

#### TextFieldの使用例

```swift
struct FormView: View {
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        VStack {
            // 枠線なしのTextField（デフォルト）
            TextField("名前を入力", text: $name)
                .frame(width: 20)
            
            // 枠線付きのTextField
            TextField("メールアドレス", text: $email)
                .frame(width: 30)
                .border()
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

#### HStackとVStackのアライメント

```swift
struct AlignmentExample: View {
    var body: some View {
        // HStackの垂直方向アライメント
        HStack(alignment: .top) {  // .top, .center(デフォルト), .bottom
            Text("ラベル:")
            TextField("入力", text: .constant(""))
                .border()
        }
        
        // VStackの水平方向アライメント
        VStack(alignment: .leading) {  // .leading, .center(デフォルト), .trailing
            Text("タイトル")
            Text("説明文")
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

#### Observableモデルの使用例（WWDC23スタイル）

```swift
// Observableプロトコルを使用したモデルクラス
class UserModel: Observable {
    var name = "Guest" {
        didSet { notifyChange() }
    }
    var age = 0 {
        didSet { notifyChange() }
    }
    var isLoggedIn = false {
        didSet { notifyChange() }
    }
    
    func login(name: String) {
        self.name = name
        self.isLoggedIn = true
    }
}

// Viewでの使用
struct UserView: View {
    @Environment(UserModel.self) var user: UserModel?
    @State private var inputName = ""
    
    var body: some View {
        if let user = user {
            VStack {
                Text("User: \(user.name)")
                    .foregroundColor(user.isLoggedIn ? .green : .red)
                
                if !user.isLoggedIn {
                    HStack {
                        TextField("Name", text: $inputName)
                        Button("Login") {
                            user.login(name: inputName)
                        }
                    }
                }
                
                Button("Age++") {
                    user.age += 1  // didSetにより手動でUI更新
                }
            }
        }
    }
}

// アプリケーションの起動
let userModel = UserModel()
SwiftTUI.run {
    UserView()
        .environment(userModel)
}
```

#### Swift標準@Observableマクロの使用例（Swift 5.9+）

SwiftTUIは、Swift 5.9以降で利用可能な標準の`@Observable`マクロもサポートしています：

```swift
import SwiftTUI
import Observation

// Swift標準の@Observableマクロを使用
@Observable
class ProductModel {
    var name = "Product"
    var price = 0.0
    var inStock = true
    
    func updatePrice(to newPrice: Double) {
        price = newPrice
    }
}

// Viewでの使用（SwiftTUI Observableと同じ方法）
struct ProductView: View {
    @Environment(ProductModel.self) var product: ProductModel?
    
    var body: some View {
        if let product = product {
            VStack {
                Text("\(product.name)")
                    .bold()
                Text("Price: $\(product.price)")
                    .foregroundColor(product.inStock ? .white : .red)
                
                Button("Update Price") {
                    product.updatePrice(to: product.price + 10.0)
                }
            }
        }
    }
}

// アプリケーションの起動
let product = ProductModel()
SwiftTUI.run {
    ProductView()
        .environment(product)
}
```

**Observable パターンの選択**
- **SwiftTUI Observable**: `didSet { notifyChange() }`パターンを使用。全てのSwiftバージョンで動作
- **標準 @Observable**: Swift 5.9+で利用可能。プロパティの変更が自動的に追跡される

#### 環境値の使用例

```swift
struct ThemedView: View {
    @Environment(\.foregroundColor) var themeColor
    @Environment(\.isEnabled) var isEnabled
    
    var body: some View {
        Text("Themed Text")
            .foregroundColor(isEnabled ? themeColor : .white)
    }
}

// 環境値を設定して使用
struct ParentView: View {
    var body: some View {
        VStack {
            ThemedView()
                .environment(\.foregroundColor, .cyan)
                .disabled(false)
        }
    }
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

##### 新しいコンポーネントの使用例

```swift
struct SettingsView: View {
    @State private var isDarkMode = false
    @State private var selectedTheme = "Blue"
    @State private var volume = 0.7
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Settings")
                .bold()
                .padding()
                .border()
            
            // Toggle
            Toggle("Dark Mode", isOn: $isDarkMode)
                .padding()
            
            // Picker
            Picker("Theme", selection: $selectedTheme, options: ["Blue", "Green", "Red", "Purple"])
                .padding()
            
            // Slider
            Slider(value: $volume, in: 0...1, label: "Volume")
                .padding()
            
            // ProgressView
            if isLoading {
                ProgressView("Loading settings...")
                    .padding()
            } else {
                ProgressView(value: 0.8, label: "Sync Progress")
                    .padding()
            }
        }
    }
}

// Alertの使用例
struct AlertExampleView: View {
    @State private var showAlert = false
    
    var body: some View {
        Button("保存") {
            showAlert = true
        }
        .alert("保存完了", isPresented: $showAlert, message: "設定が保存されました")
    }
}
```

### 操作方法

- **Tab / Shift+Tab**: フォーカスの移動
- **Enter / Space**: ボタンのクリック、Toggle切り替え、Picker開閉、Alert閉じる
- **文字入力**: TextFieldへの入力
- **Backspace**: 文字の削除
- **←→**: カーソルの移動（TextField内）、Slider値の調整
- **↑↓**: ScrollView内でのスクロール、Picker選択肢の移動
- **Home/End**: Sliderの最小値/最大値へジャンプ
- **ESC**: Pickerを閉じる、Alertを閉じる、プログラムの終了
- **Ctrl+C**: 強制終了

### StateTestの動作確認

StateTestはグローバル状態管理とキーボードショートカットの動作を確認するサンプルです：

```bash
swift run StateTest

# キー操作
u - カウンターを増やす (increment)
d - カウンターを減らす (decrement)  
m - メッセージを切り替える (Hello ⇔ World)
q - プログラムを終了
```

このテストでは、キーボードショートカットで状態を変更し、画面が自動的に更新されることを確認できます。

### ScrollViewの動作確認

SimpleScrollTestを実行してScrollViewのスクロール機能を確認できます：

```bash
swift run SimpleScrollTest

# キー操作
↑ - 上にスクロール
↓ - 下にスクロール
ESC - プログラムを終了
```

このテストでは、5つの項目を持つScrollViewが表示され、ビューポートは3行に制限されています。
矢印キーで残りのコンテンツをスクロールして表示できます。

### ForEachの動作確認

ForEachの各種パターンを確認できます：

```bash
# シンプルなForEachテスト（Range使用）
swift run SimpleForEachTest

# 複雑なForEachテスト（Identifiable、Range、KeyPath）
swift run ForEachTest

# デバッグ用テスト（HStack内でのForEach）
swift run ForEachDebugTest

# 表示問題の調査用テスト
swift run BorderHStackTest    # HStackでのボーダー重複を確認
swift run SimpleBackgroundTest # 背景色の基本動作を確認
```

ForEachTestでは以下の3つのパターンが表示されます：
1. **Identifiable**: カスタム構造体の配列を使用
2. **Range**: `0..<5`のような範囲を使用
3. **KeyPath**: 文字列配列で`id: \.self`を使用

#### 既知の問題

ForEach自体は正しく動作していますが、以下の組み合わせで表示が崩れる場合があります：
- HStack内でborder()を使用した場合：境界線が重なって表示される
- background()モディファイアとの組み合わせ：HStack内では最後の要素の背景色のみが表示される

これらは関連コンポーネント（HStack、BackgroundLayoutView、bufferWrite）の問題であり、ForEachの実装自体は正常です。

##### 問題の詳細
- **原因**: bufferWrite関数が単純な文字単位の上書きを行うため、HStack内で後の要素が前の要素を上書き
- **影響**: ボーダーの重複、背景色の消失、ANSIエスケープシーケンスの混在
- **対策**: レンダリングアーキテクチャの改善が必要（レイヤーベースの描画システムなど）

### ButtonFocusTestの動作確認

ButtonFocusTestは@Stateプロパティラッパーとボタンフォーカス機能を確認するサンプルです：

```bash
swift run ButtonFocusTest

# 操作方法
Tab - 次のボタンにフォーカスを移動
Enter/Space - フォーカスされているボタンを押す
q - プログラムを終了

# 利用可能なボタン
Count++ - カウンターを増やす
Count-- - カウンターを減らす
Toggle Message - メッセージを切り替える (Hello ⇔ World)
Reset - すべてをリセット
```

このテストでは、@Stateプロパティの変更が自動的にUIに反映され、Tabキーでボタン間を移動できることを確認できます。

**注記**: Tab キーナビゲーションの問題が修正されました。以前は以下の問題がありましたが、現在は正常に動作します：
- CellRenderLoopとFocusManagerの統合に不整合があり、Tab キーが反応しない問題
- Tab キーで移動しても前のボタンのフォーカス状態が残る問題

#### Tab キーナビゲーションの確認方法

1. プログラムを起動すると、最初のボタン「Count++」が緑色の枠線と背景で表示されます（フォーカス状態）
2. Tab キーを押すと、フォーカスが次のボタンに移動します：
   - Count++ → Count-- → Toggle Message → Reset → Count++（循環）
3. フォーカスされたボタンは緑色で強調表示されます
4. Enter または Space キーでフォーカスされたボタンを実行できます
5. Tab キーを4回押すと最初のボタンに循環して戻ります（他のボタンのフォーカスは解除されます）

#### Tab循環の動作確認

Tab キーの循環動作を自動的にテストできます：

```bash
# Tab キーを4回押して循環動作を確認
{ sleep 2; echo -e "\t"; sleep 1; echo -e "\t"; sleep 1; echo -e "\t"; sleep 1; echo -e "\t"; sleep 2; echo -e "q"; } | swift run ButtonFocusTest

# 期待される動作：
# 1. Count++ (初期フォーカス)
# 2. Count-- (1回目のTab)  
# 3. Toggle Message (2回目のTab)
# 4. Reset (3回目のTab)
# 5. Count++ (4回目のTab - 循環)
# すべての遷移で、1つのボタンのみが緑色で表示される
```

#### Tabキーナビゲーションのデバッグ

Tabキーナビゲーションに問題が発生した場合、以下の方法でデバッグできます：

```bash
# 最小限のボタンテスト
swift run MinimalButtonTest

# デバッグ情報の確認
# MinimalButtonTestはstderrにデバッグログを出力します
# Tabキーイベントが正しく処理されているか確認できます
```

**技術的詳細**：
- `ButtonLayoutManager`がButtonLayoutViewインスタンスを管理
  - 再レンダリング時に`prepareForRerender()`ですべてのボタンのフォーカス状態をリセット
- `FocusManager`がフォーカス可能なViewを追跡
  - 再レンダリング中は`isRerendering`フラグで自動フォーカスを抑制
  - `finishRerendering()`ですべてのビューが登録された後にフォーカスを復元
- `CellRenderLoop`がレンダリング前に両マネージャーを準備し、レンダリング後に完了を通知

### ListTestの動作確認

ListTestはListコンポーネントの動作を確認するサンプルです：

```bash
swift run ListTest

# 表示内容
- Basic List: ForEachを使用した動的リスト（現在は内容が表示されない問題あり）
- Static List: 静的に配置したアイテムのリスト（正常に表示）
```

プログラムは5秒後に自動的に終了します。Range errorは修正済みで、クラッシュすることなく動作します。

### スクロール機能について

SwiftTUIでは、SwiftUIとは異なり、Listコンポーネント自体はスクロール機能を持ちません。スクロール可能なリストを作成するには、ScrollViewで明示的に囲む必要があります：

```swift
// SwiftUIでは自動的にスクロール可能
List(items) { item in
    Text(item.name)
}

// SwiftTUIでは明示的にScrollViewが必要
ScrollView {
    List {
        ForEach(items) { item in
            Text(item.name)
        }
    }
}
.frame(height: 10)  // ビューポートの高さを指定
```

#### スクロール関連のテスト

```bash
# ScrollViewの基本的な使い方
swift run ScrollViewTest

# Listをスクロール可能にする方法の例（ForEachの表示問題あり）
swift run ScrollableListTest

# スクロールの仕組みを説明するシンプルな例
swift run SimpleScrollableListTest

# 矢印キー入力のテスト
swift run ArrowKeyTest

# シンプルなスクロールテスト（スクロール描画は未実装）
swift run SimpleScrollTest
```

#### スクロール操作

- **↑↓**: ScrollView内でコンテンツをスクロール
- スクロールバーが表示され、現在の位置を確認できます
- frameで指定した高さ以上のコンテンツがある場合のみスクロール可能

**注意**: 2025年7月現在、矢印キーの認識は実装済みですが、実際のスクロール描画（コンテンツのクリッピング）は未実装です。

### 日本語文字幅修正の動作確認

2025年7月に修正された日本語文字幅問題を確認するためのテストプログラム：

```bash
# 日本語文字幅のデバッグ用テスト
swift run SimpleBorderTest

# 表示内容：
# - 日本語テキスト「おしまい \(^o^)/」がボーダー内で正しく中央に配置される
# - 英語テキスト「Hakata.swift 2025-07-18」も同様に中央配置
# - 'q'キーで終了
```

この修正により、以下の問題が解決されました：
- 日本語文字（全角文字）がターミナル上で2セル分の幅を持つことが正しく考慮される
- CJK文字、絵文字、ASCII文字の表示幅が正確に計算される
- TextField内でのカーソル位置が日本語入力時も正しく表示される
- Sliderやボーダー内のテキストが正しく中央寄せされる
- **追加修正（2025年1月18日）**: TextFieldで日本語文字が「名前」→「名 前」と余計なスペースで表示される問題を修正

### DemoForLTの動作確認

DemoForLTは日本語を含むインタラクティブフォームのデモです：

```bash
# Examples/DemoForLT ディレクトリで実行
cd Examples/DemoForLT
swift run DemoForLT

# またはプロジェクトルートから実行
swift run --package-path Examples/DemoForLT DemoForLT
```

確認ポイント：
- 「ユーザー登録」が正しく表示される（「ユ ー ザ ー 登 録」のようにスペースが入らない）
- 「名前:」「送信」などの日本語テキストが正しく表示される
- Tabキーでフォーカスを移動、Enterキーでボタンを押す
- qキーで終了

#### 修正の技術的詳細

以下のコンポーネントで文字幅計算が修正されました：
- `StringWidth.swift`: Unicode文字の表示幅を正確に計算するユーティリティ
- `CellText.swift`: テキスト表示時の幅計算
- `Alert.swift`: アラート内のテキスト中央寄せ
- `TextField.swift`: カーソル位置と文字幅の正確な処理
- `Border.swift`: ボーダー内のコンテンツ幅計算
- `BufferCell.swift`: 最も重要な修正 - 日本語文字が2セルを占有するように

### 動作確認時の便利なTips

#### echoコマンドを使った自動テスト

インタラクティブなプログラムの動作確認時に、echoコマンドでキー入力を自動化できます：

```bash
# StateTestの自動テスト例
# u を2回、d を1回、m を1回押してから q で終了
echo -e "u\nu\nd\nm\nq" | swift run StateTest

# ButtonFocusTestの自動テスト例  
# Tabを3回押して3番目のボタンにフォーカス、Enterで押してから q で終了
echo -e "\t\t\t\n\nq" | swift run ButtonFocusTest

# 複数のキー入力を時間差で送る例（bashスクリプト）
(sleep 1; echo -e "\t"; sleep 1; echo -e "\n"; sleep 1; echo "q") | swift run ButtonFocusTest
```

#### テスト出力の保存

```bash
# 出力をファイルに保存
swift run StateTest 2>&1 | tee state_test_output.txt

# 特定の部分だけを確認
echo -e "u\nu\nq" | swift run StateTest 2>&1 | grep "Counter:"

# 最後の画面状態を確認
echo -e "\t\nq" | swift run ButtonFocusTest 2>&1 | tail -30
```

#### デバッグ時のTips

- プログラムが応答しない場合は `Ctrl+C` で強制終了
- ターミナルの表示が崩れた場合は `reset` コマンドでリセット
- ANSIエスケープシーケンスを確認したい場合は `cat -v` を使用

### ObservableModelTestの動作確認

ObservableModelTestはSwiftTUIの状態管理機能（WWDC23スタイル）を確認するサンプルです：

```bash
swift run ObservableModelTest

# 操作方法
Tab - ボタン間の移動
Enter/Space - ボタンのクリック
q/ESC - プログラムの終了

# 確認できる機能
- Observableプロトコルの実装
- didSetでのnotifyChange()による手動変更通知
- @Environmentによる環境値の参照
- .environment()モディファイアによるObservableインスタンスの設定
```

このテストでは、シンプルなカウンターモデルを使用して、Observable の変更が手動通知により自動的にUIに反映されることを確認できます。

### SimpleObservableTestの動作確認

SimpleObservableTestはObservableパターンの基本的な使い方を確認するサンプルです：

```bash
swift run SimpleObservableTest

# 操作方法
Tab - Updateボタンへフォーカス
Enter/Space - Updateボタンのクリック
q/ESC - プログラムの終了

# 確認できる機能
- MessageModelのObservable実装
- didSetでのnotifyChange()呼び出し
- Updateボタンクリックによる動的な状態変更
- @Environmentを通じたObservableインスタンスの共有
```

このテストでは、メッセージとカウントを持つシンプルなモデルを使用して、
ボタンクリックによる状態変更がUIに反映されることを確認できます。

### Observable実装の動作確認

SwiftTUIは、WWDC23スタイルのObservableパターンをサポートしています：

#### 基本的な使い方

```swift
// Observableクラスの定義
class UserModel: Observable {
    var name = "Guest" {
        didSet { notifyChange() }
    }
    var age = 0 {
        didSet { notifyChange() }
    }
}

// Viewでの使用
struct ContentView: View {
    @Environment(UserModel.self) var userModel: UserModel?
    
    var body: some View {
        if let userModel = userModel {
            Text("\(userModel.name), age: \(userModel.age)")
        } else {
            Text("No user model")
        }
    }
}

// アプリケーションの起動
let userModel = UserModel()
SwiftTUI.run(
    ContentView()
        .environment(userModel)
)
```

#### 重要なポイント

1. **手動通知パターン**: `didSet { notifyChange() }` で変更を通知
2. **@Environment経由の参照**: Observable型は@Environmentで取得（Optional型として）
3. **.environment()での設定**: Observableインスタンスを環境に注入

### トラブルシューティング

#### プログラムがすぐに終了してしまう場合

以前のバージョンでは、`swift run` でプログラムを実行するとすぐに終了してしまう問題がありました。
この問題は修正済みですが、もし発生した場合は以下を確認してください：

1. SwiftTUIの最新バージョンを使用していることを確認
2. `SwiftTUI.run()` を使用してアプリケーションを起動していることを確認

#### Observable実装で表示されない場合

最新バージョンで修正済みですが、以下の点を確認してください：

1. **padding問題（修正済み）**: VStackに`.padding()`を適用するとサイズが0になる問題は修正されました
2. **Environment無限ループ（修正済み）**: `.environment()`使用時のハング問題は修正されました

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
swift run StateTest           # グローバル状態管理の動作確認（u/d/mキーで値を変更、qで終了）
swift run ButtonFocusTest     # ボタンフォーカス機能のテスト（Tab/Enter操作、@State使用）
swift run KeyTestVerify       # グローバルキーハンドラーの動作確認（自動テスト）

# ✅ 修正済みのサンプル
swift run ListTest            # Listコンポーネントのテスト（Range error修正済み）
swift run MinimalListTest     # シンプルなListのテスト

# ✅ 修正完了したサンプル（以前は問題あり）
swift run ScrollViewTest      # Range error修正済み - 正常に動作します
swift run ForEachTest         # ViewBuilder制限を10個まで拡張 - コンパイル可能（表示の問題は残存）
swift run InteractiveFormTest # ESCキー修正により解決済み - 正常に終了できます
```

#### 既知の問題と回避策

1. **Float→Int変換エラー**: Yogaレイアウトエンジンから返される値がNaNやinfiniteの場合があります。これは修正済みです。

2. **Range error**: ForEachやListを使用する際に発生する場合があります。ScrollViewTestのRange errorは修正済みです。

3. **ViewBuilder制限**: ~~1つのブロック内に5つ以上のViewを配置できません。~~ **修正済み**: 最大10個のViewまで配置できるように拡張しました。

4. **HStack内での表示問題**: 
   - ボーダーが重なって表示される
   - 背景色が最後の要素のみ表示される
   - 原因: bufferWrite関数の単純な上書き処理
   - 根本的な解決にはレンダリングアーキテクチャの改善が必要

### セルベースレンダリングの動作確認

セルベースレンダリングの実装により、HStack内での背景色問題が修正されました：

```bash
# HStack内での背景色レンダリングテスト
swift run ManualCellTest

# 表示内容：
# - 3つの要素（A=赤背景、B=緑背景、C=青背景）がすべて正しく表示されます
# - 以前の問題（最後の要素の背景色のみ表示）が修正されています
```

#### セルベースレンダリングの特徴

- **Cell構造体**: 各文字の位置に文字、前景色、背景色を保持
- **CellBuffer**: 画面全体をセルの2次元配列として管理
- **正しい重ね合わせ**: 背景色と文字を別々に管理することで、正しい描画順序を実現

#### 関連テストプログラム

```bash
# HStackの背景色テスト（修正前の問題を確認）
swift run HStackBackgroundDebugTest

# 手動でセルベースレンダリングを確認
swift run ManualCellTest

# ForEachとセルベースレンダリングの組み合わせ
swift run ForEachCellTest  # ForEachRange使用の例
```

### テストプログラムの実行と自動化

#### Phase 4 コンポーネントのテスト

Phase 4で実装された新しいコンポーネントのテストプログラム：

```bash
# Toggleコンポーネント - オン/オフ切り替え
swift run ToggleTest

# Pickerコンポーネント - ドロップダウン選択
swift run PickerTest

# ProgressViewコンポーネント - 進捗表示（5秒後に自動終了）
swift run ProgressViewTest

# Sliderコンポーネント - 値の範囲選択
swift run SliderTest

# Alertコンポーネント - .alert()モディファイア使用
swift run AlertTest
```

#### 自動テストスクリプト

各テストプログラムには自動実行用のスクリプトが用意されています：

```bash
# SimpleTestの自動実行（5秒後に自動終了）
./scripts/SimpleTest/test.sh

# AlertTestの自動実行（ボタン操作とアラート表示を自動化）
./scripts/AlertTest/test.sh

# ButtonFocusTestの自動実行（Tab移動とボタンクリックを自動化）
./scripts/ButtonFocusTest/test.sh
```

各スクリプトは以下の機能を提供します：
- キー入力の自動シミュレーション
- 出力のファイル保存（`scripts/{TEST_NAME}/output.txt`）
- 最終画面のスクリーンショット保存（`scripts/{TEST_NAME}/screenshot.txt`）

#### テスト結果の確認

すべてのテストプログラムの実行結果と詳細は`TEST_RESULTS.md`にまとめられています。
このドキュメントには以下の情報が含まれます：

- 各テストの期待される挙動
- 実行結果と動作確認状況
- 作成された自動テストスクリプトの一覧
- 今後の課題と推奨事項

#### テストプログラムのドキュメント

すべてのテストプログラム（65個）には標準化されたヘッダーコメントが追加されています。
各テストファイルの先頭に以下の情報が記載されています：

```swift
// TestName - テストの概要説明
//
// 期待される挙動:
// 1. 具体的な動作の説明
// 2. 表示される内容
// 3. 操作方法
// ...
//
// 注意: テストの目的や既知の問題
//
// 実行方法: swift run TestName
```

例えば、`Sources/SimpleTest/main.swift`では：

```swift
// SimpleTest - SwiftUIライクな構文の基本的な動作確認
//
// 期待される挙動:
// 1. "Hello, SwiftTUI!"というメッセージがシアン色で表示される
// 2. "This is a terminal UI framework"というメッセージが白色で表示される
// 3. 両方のメッセージが縦に並んで表示される（VStack）
// 4. ESCキーでプログラムが終了する
//
// 注意: 最も基本的なテストケースで、Text ViewとVStackの動作を確認します
//
// 実行方法: swift run SimpleTest
```

このドキュメント化により、各テストプログラムの目的と期待される動作が明確になり、
新しい開発者がコードベースを理解しやすくなっています。

### ユニットテスト

SwiftTUIにはユニットテストが含まれています。テストはXCTestフレームワークを使用して書かれています。

#### テストの実行

```bash
# すべてのテストを実行
swift test

# 特定のテストクラスを実行
swift test --filter SwiftTUITests.TextTests
swift test --filter SwiftTUITests.SpacerTests
swift test --filter SwiftTUITests.BindingTests
swift test --filter SwiftTUITests.EnvironmentTests
swift test --filter SwiftTUITests.ForEachTests
swift test --filter SwiftTUITests.ListTests
swift test --filter SwiftTUITests.ScrollViewTests
swift test --filter SwiftTUITests.ToggleTests
swift test --filter SwiftTUITests.PickerTests
swift test --filter SwiftTUITests.SliderTests
swift test --filter SwiftTUITests.AlertTests
swift test --filter SwiftTUITests.ProgressViewTests

# 特定のテストメソッドを実行
swift test --filter SwiftTUITests.TextTests.testTextBasic
swift test --filter SwiftTUITests.SpacerTests.testSpacerInVStackPushesContentApart
swift test --filter SwiftTUITests.EnvironmentTests.testEnvironmentForegroundColor
swift test --filter SwiftTUITests.EnvironmentTests.testSwiftTUIObservableInEnvironment
swift test --filter SwiftTUITests.ForEachTests.testForEachRangeBasic
swift test --filter SwiftTUITests.ForEachTests.testForEachIdentifiableBasic
swift test --filter SwiftTUITests.ListTests.testListBasicDisplay
swift test --filter SwiftTUITests.ListTests.testListWithForEachRange
swift test --filter SwiftTUITests.ScrollViewTests.testScrollViewBasicVertical
swift test --filter SwiftTUITests.ScrollViewTests.testScrollViewContentClipping
swift test --filter SwiftTUITests.PickerTests.testPickerBasicStringOptions
swift test --filter SwiftTUITests.PickerTests.testPickerFocusDisplay
swift test --filter SwiftTUITests.SliderTests.testSliderBasicDisplay
swift test --filter SwiftTUITests.SliderTests.testSliderBinding
swift test --filter SwiftTUITests.AlertTests.testAlertBasicDisplay
swift test --filter SwiftTUITests.AlertTests.testAlertModifierShowing
swift test --filter SwiftTUITests.ProgressViewTests.testProgressViewIndeterminateBasic
swift test --filter SwiftTUITests.ProgressViewTests.testProgressViewDeterminateWithLabel
```

#### テストの内容

- **TextTests**: Text viewの基本的な動作をテスト
  - 基本的なテキスト表示
  - 特殊文字、Unicode、改行の処理
  - 文字列補間のサポート

- **TextModifierTests**: Text viewのモディファイアをテスト
  - `.padding()`, `.border()`, `.bold()`
  - `.foregroundColor()`, `.background()`
  - モディファイアの連鎖

- **CompositeViewTests**: 複合ビューの動作をテスト
  - VStack, HStackでのテキスト配置
  - ネストされたスタック
  - スペーシングのサポート

- **SpacerTests**: Spacerビューの動作をテスト
  - 基本的なSpacer動作（単体では何も表示しない）
  - VStack内での垂直方向の拡張
  - HStack内での水平方向の拡張
  - 複数Spacerでの均等なスペース分配
  - ネストされたSpacer
  - エッジケース（スペースなし、最小高さ）

- **TextFieldTests**: TextFieldビューの動作をテスト
  - 基本的なTextField表示（空のテキスト、初期値あり）
  - @Bindingの動作（親子関係、値の反映）
  - プレースホルダーの表示/非表示（長いプレースホルダー、空のプレースホルダー）
  - ボーダー構造の検証（Unicode box drawing characters）
  - サイズとレイアウト（コンテンツに応じたサイズ調整）
  - VStack内での複数TextField
  - エッジケース（特殊文字、複数バインディング）
  - フレームモディファイアとの組み合わせ

- **ButtonTests**: Buttonビューの動作をテスト
  - 基本的なButton表示（文字列ラベル、カスタムViewラベル）
  - ボーダー構造の検証（Unicode box drawing characters）
  - パディングの検証（左右上下のパディング）
  - フォーカス状態の表示（デフォルトで非フォーカス）
  - VStack/HStack内での配置
  - 複数ボタンの水平配置（HStack）
  - フレームモディファイアとの組み合わせ
  - ネストされたスタック内での複数ボタン配置
  - エッジケース（空ラベル、長いラベル、複数行ラベル）

- **ToggleTests**: Toggleビューの動作をテスト
  - 基本表示機能（OFF状態 [ ]、ON状態 [✓]、ラベル表示）
  - 複数トグルの独立動作（各トグルが独立した状態を保持）
  - @Binding状態管理（親子コンポーネント間のバインディング、初期値の反映）
  - 複数の独立したバインディング（複数のトグルが異なるバインディングを持つ）
  - フォーカス管理（フォーカス可能表示、レイアウト内でのサイズ計算）
  - エッジケース（空ラベル、長いラベル、特殊文字・絵文字）
  - VStack内での複雑なレイアウト（他のコンポーネントとの組み合わせ）

- **PickerTests**: Pickerドロップダウン選択コンポーネントの動作をテスト
  - 基本表示機能（ラベル: [選択値 ▼] 形式、String型選択肢での表示）
  - @Binding選択管理（選択値の初期表示、状態管理、複数バインディング）
  - フォーカス管理（フォーカス状態の表示、複数Pickerの独立管理）
  - エッジケース（空選択肢配列、単一選択肢、長いラベル・選択肢名）
  - 特殊文字・絵文字での動作（Unicode文字、括弧等の特殊記号）
  - 注意：Int型Pickerでsignal 11クラッシュが発生するため、現在はString型のみでテスト実装
  - TestRenderer互換性問題により、独自の`renderPicker`ヘルパーメソッドを使用

- **SliderTests**: Slider値調整コンポーネントの動作をテスト
  - 基本表示機能（ラベル: [バー] 値 形式、範囲に応じた表示、異なる型のサポート）
  - @Binding値管理（初期値の反映、値の更新と同期、複数スライダーの独立管理）
  - 範囲とステップ機能（カスタム範囲、ステップ指定、境界値での動作）
  - フォーカス管理（フォーカス状態での枠線表示、サイズ計算、複数Sliderの独立管理）
  - エッジケース（極小値・極大値、ゼロ範囲回避、長いラベル、特殊文字・絵文字）
  - TestRenderer互換性問題により、独自の`renderSlider`ヘルパーメソッドを使用

- **AlertTests**: Alert表示コンポーネントの動作をテスト
  - 基本表示機能（赤い警告枠、タイトル表示、OKボタン、中央寄せ）
  - @Binding表示制御（isPresentedでの表示/非表示、dismissアクションでの状態変更）
  - モディファイア動作（.alert()でのコンテンツ切り替え、アラート表示時のコンテンツ隠蔽）
  - エッジケース（長いタイトル・メッセージ、メッセージなし、特殊文字・絵文字）
  - 独自の`renderAlert`ヘルパーメソッドでdirect alert testing対応

- **ProgressViewTests**: ProgressView進捗表示コンポーネントの動作をテスト
  - 基本表示機能（不確定進捗スピナー、確定進捗バー、ラベル付き/なし）
  - 進捗値管理（0-100%表示、範囲外値のクランプ、カスタムtotal値、パーセンテージ計算）
  - スタイル・レイアウト（20文字固定幅バー、塗りつぶし█と空白░の正確な比率、要素間スペーシング）
  - エッジケース（0%/100%進捗、特殊文字・絵文字ラベル）
  - スピナーアニメーション文字（⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏）の確認

- **BindingTests**: @Bindingプロパティラッパーの動作をテスト
  - 親子View間のバインディング同期（TextField、Toggle）
  - 複数の子Viewで同じBindingを共有
  - ネストされたView階層でのBinding伝播
  - Binding.constantによる読み取り専用バインディング（異なる型のサポート）
  - カスタムBindingによる値の変換（温度変換）と検証（範囲制限）
  - 異なるViewタイプでのBinding動作（Slider、Picker）
  - Optional値の処理（nil/非nil値の変換）
  - projectedValueの動作（Bindingの再取得）

- **EnvironmentTests**: @Environmentプロパティラッパーの動作をテスト
  - 基本的な環境値の取得（foregroundColor、isEnabled、fontSize）
  - View階層での環境値の伝播（親子関係、値の上書き、深いネスト）
  - SwiftTUI Observable型の環境設定と取得
  - 標準@Observable型の環境設定と取得（Swift 5.9+）
  - SwiftTUIとStandard Observableの混在使用
  - カスタム環境キーの定義とアクセス
  - エッジケース（複数環境値、disabled()メソッド、条件付きView）

- **ForEachTests**: ForEach動的リスト生成の動作をテスト
  - Range-based ForEach（ForEachRange）の基本動作とエッジケース
  - Identifiable配列でのForEach動作（空配列、単一要素、複数要素）
  - KeyPath ID（id: \.self）での文字列・整数配列処理
  - カスタムKeyPath（id: \.username）での構造体配列処理
  - ネストされたForEach（二重ループ）の動作確認
  - 複雑なレイアウト（VStack+ForEach+padding+border）との組み合わせ
  - エッジケース（大きな数値Range、重複ID、HStack内での使用）

- **ListTests**: List自動区切り線付きリスト表示の動作をテスト
  - 基本的なList表示（静的コンテンツ、空List、単一/複数項目）
  - セパレーター自動挿入の動作（項目間の区切り線、最後の項目後は挿入なし）
  - ForEachとの組み合わせ（Range、Identifiable、KeyPath ID対応）
  - モディファイアとの組み合わせ（padding、border）
  - ネストされたView（VStack内のList、List内のVStack）
  - エッジケース（長いコンテンツ、VStack内での配置）
  - 注意：List実装には既知の制限（中間項目の消失）があり、テストで考慮済み

- **ScrollViewTests**: ScrollViewスクロール可能コンテナの動作をテスト
  - 基本スクロール機能（垂直、水平、両方向、スクロール不要、空コンテンツ）
  - フレーム制約とクリッピング（固定ビューポート3行×5文字、長いテキストの切り詰め）
  - スクロールバー表示（showsIndicators設定、大きなコンテンツでの動作）
  - ANSIエスケープシーケンス処理（色付きテキストの保持）
  - エッジケース（単一行、ネストされたView、VStack内配置、複数インスタンス）
  - 注意：現在の実装は固定ビューポートサイズで、.frame()モディファイアは無視される
  - グローバル状態管理により複数ScrollView間で状態が共有される制限あり

- **FrameModifierTests**: .frame()モディファイアの動作をテスト
  - 幅制約のみのテスト（短いテキスト、長いテキスト、パディング）
  - 高さ制約のみのテスト（少ない行数、多い行数、余白）
  - 幅と高さ両方の制約（収まる場合、超える場合）
  - 他のモディファイアとの組み合わせ（padding、border、複数frame）
  - VStack/HStack内でのframe動作
  - エッジケース（ゼロサイズ、非常に大きなサイズ）

- **StateTests**: @Stateプロパティラッパーの動作をテスト
  - 初期値の表示（文字列、整数、Bool、カスタム型）
  - 複数の@Stateプロパティ（独立性、異なる型の組み合わせ）
  - ネストされたView間での@State独立性
  - 同一Viewの複数インスタンスでの独立した状態
  - @Bindingへの変換（projectedValue: $state）
  - エッジケース（空文字列、Optional値、配列）

#### 全テストプログラムの一括実行

`scripts/all-test.sh`を使用すると、すべてのテストプログラムを順番に実行できます：

```bash
# timeoutコマンドの確認（macOSの場合）
./scripts/check-timeout.sh

# 必要に応じてcoreutilsをインストール
brew install coreutils

# 全テストを実行
./scripts/all-test.sh
```

このスクリプトの特徴：
- Sources/ディレクトリ内のすべての*Testプログラムを自動検出
- 各テストにタイムアウトを設定（デフォルト10秒、テストごとにカスタマイズ可能）
- タイムアウトコマンドがない環境でも動作（代替処理を実装）
- カラー出力で結果を視覚的に表示
- 実行結果をログファイルに保存
  - `scripts/all-test-results.log`: 詳細な実行ログ
  - `scripts/all-test-summary.txt`: 結果サマリー

実行結果の例：
```
=== SwiftTUI All Tests Runner ===
Checking timeout command availability...
⚠ Neither timeout nor gtimeout found. Using fallback method.

[1] Running: SimpleTest (timeout: 10s)
Building for debugging...
[3/7] Compiling SimpleTest main.swift
Build of product 'SimpleTest' complete! (2.45s)
Hello, SwiftTUI!
This is a terminal UI framework
✓ PASSED (3 seconds)

[2] Running: ScrollViewTest (timeout: 20s)
Building for debugging...
Build of product 'ScrollViewTest' complete! (1.85s)
[スクロールビューの内容が表示される]
✗ TIMEOUT

=== Test Results Summary ===
Total tests: 65
Passed: 50
Failed: 5
Timeout: 10
```

**注意事項**：
- 初回実行時はビルドに時間がかかるため、タイムアウトが発生しやすくなります
- 2回目以降はビルドキャッシュが効くため、より多くのテストが成功します
- `Ctrl+C`で実行を中断できます
- タイムアウトしたテストは個別に `swift run TestName` で実行して確認してください


