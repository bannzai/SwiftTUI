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
  
  /* アニメーション定義 */
  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
  }
  
  @keyframes bounce {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-10px); }
  }
  
  @keyframes rotate {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }
  
  /* タイトルのフェードイン */
  h1 {
    animation: fadeIn 1s ease-out;
  }
  
  /* 自己紹介画像のバウンス */
  img[alt*="bannzai"] {
    animation: bounce 2s infinite ease-in-out;
  }
  
  /* コードブロックのフェードイン */
  pre {
    animation: fadeIn 0.8s ease-out;
  }
  
  /* 特定のスライドクラス用 */
  section.profile li {
    animation: fadeIn 1s ease-out;
    animation-fill-mode: both;
  }
  section.profile li:nth-child(1) { animation-delay: 0.3s; }
  section.profile li:nth-child(2) { animation-delay: 0.6s; }
  section.profile li:nth-child(3) { animation-delay: 0.9s; }
  
  /* コードサンプルのスライドで背景を少し変える */
  section.code-demo {
    background-color: #f8f9fa;
  }
  
  /* 最後のスライド用のクラス */
  section.thanks {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
  }
  section.thanks h1 {
    animation: fadeIn 1s ease-out, bounce 2s 1s infinite ease-in-out;
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

<!-- _class: profile -->

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

<!-- _class: code-demo -->

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

<!-- _class: thanks -->

GitHub: **github.com/bannzai/SwiftTUI**

⭐ Starもらえると嬉しいです！

---