---
marp: true
theme: default
paginate: true
style: |
  section {
    font-size: 28px;
  }
  h1 {
    font-size: 48px;
  }
  h2 {
    font-size: 36px;
  }
  pre {
    font-size: 22px;
  }
---

<!-- 
Marpの使い方:
1. VSCode拡張機能 "Marp for VS Code" をインストール
2. このファイルを開いてプレビュー表示（右上のアイコン）
3. またはCLI: npm install -g @marp-team/marp-cli && marp -s SLIDES.md
-->

---

# SwiftTUI

ターミナルでSwiftUIを書こう！

---

## 自己紹介

![width:300px](bannzai.programmer.png)

**@bannzai**
- iOSエンジニア
- SwiftUI大好き
- ターミナルも大好き

---

## SwiftTUIとは？

SwiftでTUI（Terminal UI）を作るライブラリ

---

## TUIって？

Terminal User Interface
= ターミナル上で動くGUI

---

## なぜ作った？

SwiftUIの書き味で
ターミナルアプリを作りたい！

---

## React Ink

```javascript
// JavaScriptにはある
import {render, Text} from 'ink';

const App = () => (
    <Text color="green">
        Hello, world!
    </Text>
);

render(<App />);
```

---

## SwiftTUIなら

```swift
import SwiftTUI

struct App: View {
    var body: some View {
        Text("Hello, world!")
            .foregroundColor(.green)
    }
}

SwiftTUI.run(App())
```

---

## デモ: Hello World

```swift
Text("Hello, SwiftTUI! 🚀")
    .foregroundColor(.cyan)
    .bold()
    .padding()
    .border()
```

```
┌─────────────────────────┐
│                         │
│  Hello, SwiftTUI! 🚀    │
│                         │
└─────────────────────────┘
```

---

## デモ: フォーム

```swift
@State private var name = ""

VStack {
    Text("ユーザー登録")
    TextField("お名前", text: $name)
        .border()
    Button("送信") { }
}
```

---

## デモ: リスト

```swift
List {
    ForEach(items, id: \.self) { item in
        Text("• \(item)")
    }
}
```

---

## 特徴1: SwiftUIライクなAPI

```swift
// SwiftUI
Text("Hello")
    .padding()
    
// SwiftTUI
Text("Hello")
    .padding()
```

完全互換！

---

## 特徴2: 宣言的UI

❌ 命令的
```swift
buffer[y][x] = "H"
buffer[y][x+1] = "i"
```

✅ 宣言的
```swift
Text("Hi")
```

---

## 特徴3: @State対応

```swift
@State private var count = 0

Button("Count: \(count)") {
    count += 1  // 自動で再描画！
}
```

---

## 実装のポイント

### セルベースレンダリング

```
前: Hello
後: Hallo
     ^
```

1文字だけ更新 = 高速！

---

## 対応コンポーネント

- Text, Button, TextField
- VStack, HStack, Spacer
- List, ScrollView
- Toggle, Picker, Slider
- Alert, ProgressView

---

## 今後の展望

- 🚀 パフォーマンス改善
- 🧩 より多くのコンポーネント
- 🎨 アニメーション対応？
- 🌍 Webバックエンド対応？

---

## まとめ

SwiftUIの書き味で
ターミナルアプリが作れる！

---

## 試してみよう

```bash
git clone https://github.com/bannzai/SwiftTUI
cd SwiftTUI/Examples/HelloWorld
swift run
```

---

# ありがとうございました！

GitHub: **github.com/bannzai/SwiftTUI**

⭐ Starもらえると嬉しいです！

---