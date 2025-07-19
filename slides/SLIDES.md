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
  
  /* 最後のスライド専用の派手なアニメーション */
  @keyframes rainbow {
    0% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
    100% { background-position: 0% 50%; }
  }
  
  @keyframes superBounce {
    0%, 20%, 50%, 80%, 100% { transform: translateY(0) scale(1) rotate(0deg); }
    10% { transform: translateY(-30px) scale(1.1) rotate(-5deg); }
    30% { transform: translateY(-15px) scale(1.05) rotate(5deg); }
    40% { transform: translateY(-30px) scale(1.1) rotate(-5deg); }
    60% { transform: translateY(-15px) scale(1.05) rotate(5deg); }
    70% { transform: translateY(-30px) scale(1.1) rotate(-5deg); }
    90% { transform: translateY(-15px) scale(1.05) rotate(5deg); }
  }
  
  @keyframes pulse {
    0% { transform: scale(1); }
    50% { transform: scale(1.3); }
    100% { transform: scale(1); }
  }
  
  @keyframes starRotate {
    from { transform: rotate(0deg) scale(1); }
    to { transform: rotate(360deg) scale(1.5); }
  }
  
  /* 最後のスライドを超派手に */
  section.thanks {
    background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab);
    background-size: 400% 400%;
    animation: rainbow 3s ease infinite;
    color: white;
    overflow: hidden;
  }
  
  section.thanks h1:first-of-type {
    font-size: 60px;
    animation: superBounce 2s infinite;
  }
  
  section.thanks p {
    font-size: 80px;
    font-weight: bold;
    background: linear-gradient(45deg, #ff0000, #ff7f00, #ffff00, #00ff00, #0000ff, #8b00ff);
    background-size: 600% 600%;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    animation: rainbow 2s ease infinite, pulse 1s ease-in-out infinite;
    filter: drop-shadow(0 0 20px rgba(255,255,255,0.8));
  }
---

```
┌───────────────────────┐
│Hakata.swift 2025-07-18│
└───────────────────────┘
```

---

# SwiftTUI

ターミナルでSwiftUIを書こう！

bannzai

---

# 注意事項

- このスライドは95% AIに作らせて勢いで公開しています。間違いがあるかも
- このプロジェクトで発表するOSSはWIPです。まだ完成してないので0.0.1まで行き着くまで使うのは待ってね

---

## 自己紹介

![width:300px](https://avatars.githubusercontent.com/u/10897361?v=4)

**@bannzai**
- SwiftUI大好き
- 熊本在住

---

## SwiftTUIとは？

SwiftでTUI（Terminal UI）を作るライブラリ

---

## TUIって？

Terminal User Interface
= ターミナル上で動くGUI

---

## 最近のTUI

![width:300px](https://github.com/anthropics/claude-code/blob/main/demo.gif)
![width:300px](https://github.com/google-gemini/gemini-cli/blob/main/docs/assets/gemini-screenshot.png)

---

## なぜ作った？

SwiftUIの書き味で
ターミナルアプリを作りたい！

---

## React Ink(Codex,Claude Code,Gemini CLIで使用されている)

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

## Example: Hello World

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

## Example: フォーム

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

## Example: リスト

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

## 対応コンポーネント

- Text, Button, TextField
- VStack, HStack, Spacer
- List, ScrollView
- Toggle, Picker, Slider
- Alert, ProgressView

---

## まとめ

SwiftUIの書き味で
ターミナルアプリが作れる！

---

# ありがとうございました！

<!-- _class: thanks -->

GitHub: **github.com/bannzai/SwiftTUI**

⭐ スターください

---

  ```
  ┌────────────────┐
  │おしまい \(^o^)/│
  └────────────────┘
  ```
  (なぜかmarkdowndだとずれる)

