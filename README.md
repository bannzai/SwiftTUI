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

# 新しいコンポーネントのテスト
swift run ToggleTest              # On/Offスイッチ
swift run PickerTest              # ドロップダウン選択
swift run ProgressViewTest        # 進捗表示（5秒後に自動終了）
swift run SliderTest              # 値選択スライダー
swift run AlertTest               # 警告ダイアログ
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


