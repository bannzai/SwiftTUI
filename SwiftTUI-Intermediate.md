# SwiftTUI中級編 - レンダリング、イベント処理、状態管理の仕組み

## はじめに

入門編では、SwiftTUIの基本的な使い方を学びました。この中級編では、SwiftTUIがどのようにSwiftUIライクなAPIを実現しているか、その内部メカニズムを理解していきます。

## 1. レンダリングシステム

### 1.1 レンダリングパイプライン

SwiftTUIのレンダリングは以下の流れで行われます：

```
1. View構造体の定義
    ↓
2. ViewをLayoutViewに変換
    ↓
3. レイアウト計算（Yoga）
    ↓
4. CellBufferへの描画
    ↓
5. ターミナルへの出力
```

### 1.2 CellRenderLoopの役割

`CellRenderLoop`は、SwiftTUIのレンダリングエンジンの心臓部です。

```swift
// CellRenderLoop.swift の概念的な動作
class CellRenderLoop {
    private var currentBuffer: CellBuffer
    private var previousBuffer: CellBuffer
    
    func buildFrame() {
        // 1. 新しいバッファを準備
        let newBuffer = CellBuffer()
        
        // 2. ViewをレンダリングしてバッファにCellを書き込む
        rootView.render(into: newBuffer)
        
        // 3. 差分を検出して更新
        updateTerminal(from: previousBuffer, to: newBuffer)
        
        // 4. バッファを入れ替え
        previousBuffer = currentBuffer
        currentBuffer = newBuffer
    }
}
```

### 1.3 差分レンダリング

効率的な画面更新のため、前回と今回の差分だけを更新します：

```swift
// 例：「Hello」を「Hi!」に変更
前回: [H][e][l][l][o][ ][ ]
今回: [H][i][!][ ][ ][ ][ ]

差分: 
- 位置1: 'e' → 'i'
- 位置2: 'l' → '!'
- 位置3: 'l' → ' '
- 位置4: 'o' → ' '
```

実際のコード：
```swift
func updateTerminal(from old: CellBuffer, to new: CellBuffer) {
    for y in 0..<height {
        for x in 0..<width {
            let oldCell = old[x, y]
            let newCell = new[x, y]
            
            if oldCell != newCell {
                // ANSIエスケープシーケンスで更新
                moveCursor(to: x, y)
                setColors(fg: newCell.foreground, bg: newCell.background)
                print(newCell.character, terminator: "")
            }
        }
    }
}
```

### 1.4 ANSIエスケープシーケンス

ターミナルの制御には、特殊な文字列（エスケープシーケンス）を使います：

```swift
// カーソル移動
print("\u{001B}[\(y);\(x)H", terminator: "")  // ESC[y;xH

// 文字色設定（緑）
print("\u{001B}[32m", terminator: "")         // ESC[32m

// 背景色設定（青）
print("\u{001B}[44m", terminator: "")         // ESC[44m

// スタイルリセット
print("\u{001B}[0m", terminator: "")          // ESC[0m
```

## 2. イベント処理システム

### 2.1 キーボード入力の取得

SwiftTUIは、ターミナルを「raw mode」に切り替えて、キー入力を1文字ずつ取得します：

```swift
// InputLoop.swift の概要
class InputLoop {
    func start() {
        // ターミナルをraw modeに設定
        var termios = termios()
        tcgetattr(STDIN_FILENO, &termios)
        termios.c_lflag &= ~(UInt(ICANON) | UInt(ECHO))
        tcsetattr(STDIN_FILENO, TCSANOW, &termios)
        
        // 非同期で入力を監視
        let source = DispatchSource.makeReadSource(fileDescriptor: STDIN_FILENO)
        source.setEventHandler {
            let char = self.readCharacter()
            self.handleKeyPress(char)
        }
        source.resume()
    }
}
```

### 2.2 キーイベントの種類

```swift
enum KeyboardEvent {
    case character(Character)     // 通常の文字
    case enter                   // Enterキー
    case tab                     // Tabキー
    case escape                  // Escキー
    case arrow(Direction)        // 矢印キー
    case delete                  // Delete/Backspace
    case ctrlC                   // Ctrl+C（終了）
}
```

### 2.3 フォーカス管理

`FocusManager`が、フォーカス可能な要素（Button、TextField等）を管理します：

```swift
// FocusManagerの動作
class FocusManager {
    private var focusableViews: [FocusableView] = []
    private var currentIndex: Int = 0
    
    func handleTab() {
        // 現在のフォーカスを外す
        focusableViews[currentIndex].isFocused = false
        
        // 次の要素にフォーカス
        currentIndex = (currentIndex + 1) % focusableViews.count
        focusableViews[currentIndex].isFocused = true
        
        // 再レンダリングをスケジュール
        CellRenderLoop.scheduleRedraw()
    }
}
```

実際の使用例：
```swift
struct FormView: View {
    @State private var name = ""
    @State private var age = ""
    
    var body: some View {
        VStack {
            TextField("名前", text: $name)  // Tab順: 1
            TextField("年齢", text: $age)   // Tab順: 2
            Button("送信") { }              // Tab順: 3
        }
    }
}
```

## 3. 状態管理の仕組み

### 3.1 @Stateの実装

`@State`は、値が変更されたときに自動的に再レンダリングをトリガーします：

```swift
@propertyWrapper
struct State<Value> {
    private var storage: StateStorage<Value>
    
    var wrappedValue: Value {
        get { storage.value }
        set {
            storage.value = newValue
            // 値が変更されたら再レンダリング
            CellRenderLoop.scheduleRedraw()
        }
    }
    
    var projectedValue: Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }
}
```

### 3.2 @Bindingの仕組み

`@Binding`は、親子間でデータを共有するための仕組みです：

```swift
struct Binding<Value> {
    let get: () -> Value
    let set: (Value) -> Void
    
    var wrappedValue: Value {
        get { get() }
        set { 
            set(newValue)
            // setterが呼ばれると、元の@Stateが更新される
            // → 自動的に再レンダリングがトリガーされる
        }
    }
}
```

使用例：
```swift
struct ParentView: View {
    @State private var text = ""
    
    var body: some View {
        ChildView(text: $text)  // $でBindingを渡す
    }
}

struct ChildView: View {
    @Binding var text: String  // 親のStateと同期
    
    var body: some View {
        TextField("入力", text: $text)
    }
}
```

### 3.3 Observableパターン

より複雑な状態管理には、`Observable`を使います：

```swift
// SwiftTUI独自のObservable
class UserSettings: Observable {
    var theme: Theme = .light {
        didSet { notifyChange() }  // 変更を通知
    }
    
    var fontSize: Int = 12 {
        didSet { notifyChange() }
    }
}

// 使用例
struct SettingsView: View {
    @Environment(UserSettings.self) var settings
    
    var body: some View {
        VStack {
            Text("現在のテーマ: \(settings.theme)")
            Button("テーマ切り替え") {
                settings.theme = settings.theme == .light ? .dark : .light
                // 自動的に再レンダリング！
            }
        }
    }
}
```

### 3.4 再レンダリングのタイミング

再レンダリングは以下のタイミングで発生します：

1. **State変更時**
   ```swift
   @State private var count = 0
   // count += 1 → 再レンダリング
   ```

2. **Binding経由の変更時**
   ```swift
   @Binding var text: String
   // text = "新しい値" → 再レンダリング
   ```

3. **Observable変更時**
   ```swift
   class Model: Observable {
       var value = 0 {
           didSet { notifyChange() }  // → 再レンダリング
       }
   }
   ```

4. **キーイベント時**
   - Tabキー押下 → フォーカス移動 → 再レンダリング
   - TextFieldへの入力 → 値更新 → 再レンダリング

## 4. 実践例：カスタムコンポーネント

### 4.1 プログレスバーの実装

```swift
struct ProgressBar: View {
    let value: Double  // 0.0〜1.0
    let width: Int = 20
    
    var body: some View {
        HStack(spacing: 0) {
            Text("[")
            ForEach(0..<width, id: \.self) { i in
                if Double(i) / Double(width) < value {
                    Text("=")
                        .foregroundColor(.green)
                } else {
                    Text(" ")
                }
            }
            Text("]")
            Text(" \(Int(value * 100))%")
        }
    }
}
```

### 4.2 インタラクティブなリスト

```swift
struct SelectableList: View {
    @State private var selectedIndex = 0
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(items.indices, id: \.self) { index in
                HStack {
                    Text(index == selectedIndex ? ">" : " ")
                        .foregroundColor(.cyan)
                    Text(items[index])
                        .foregroundColor(index == selectedIndex ? .white : .gray)
                }
            }
        }
        .onKeyPress { event in
            switch event {
            case .arrow(.up):
                selectedIndex = max(0, selectedIndex - 1)
            case .arrow(.down):
                selectedIndex = min(items.count - 1, selectedIndex + 1)
            default:
                break
            }
        }
    }
}
```

## 5. パフォーマンスのヒント

### 5.1 不要な再レンダリングを避ける

```swift
// ❌ 悪い例：全体が再レンダリングされる
struct BadView: View {
    @State private var counter = 0
    
    var body: some View {
        VStack {
            ExpensiveView()  // counterが変わるたびに再計算
            Text("\(counter)")
            Button("+") { counter += 1 }
        }
    }
}

// ✅ 良い例：必要な部分だけ更新
struct GoodView: View {
    var body: some View {
        VStack {
            ExpensiveView()  // 一度だけ計算
            CounterView()    // この部分だけ再レンダリング
        }
    }
}

struct CounterView: View {
    @State private var counter = 0
    
    var body: some View {
        HStack {
            Text("\(counter)")
            Button("+") { counter += 1 }
        }
    }
}
```

### 5.2 計算プロパティの活用

```swift
struct DataView: View {
    let items: [Item]
    
    // 毎回計算せず、キャッシュする
    private var sortedItems: [Item] {
        items.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        ForEach(sortedItems, id: \.id) { item in
            Text(item.name)
        }
    }
}
```

## まとめ

中級編では、SwiftTUIの3つの核心技術を学びました：

1. **レンダリングシステム**：CellBufferと差分更新による効率的な描画
2. **イベント処理**：raw modeでのキー入力取得とフォーカス管理
3. **状態管理**：@State、@Binding、Observableによる自動再レンダリング

これらの仕組みにより、SwiftTUIはSwiftUIと同じような開発体験を提供しています。

次の詳細編では、Yogaレイアウトエンジン、セルレンダリングの詳細実装、プロセス管理について、さらに深く掘り下げていきます。