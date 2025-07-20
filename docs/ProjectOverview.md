# SwiftTUI

SwiftUIの宣言的UIパラダイムをターミナルアプリケーションに提供するSwiftフレームワーク

## 特徴

- **SwiftUI互換API**: SwiftUI開発者が最小限の学習コストで使用可能
- **日本語完全対応**: East Asian Width対応による正確な文字幅計算
- **高性能レンダリング**: セルベース差分更新による効率的な描画
- **豊富なコンポーネント**: Text, Button, TextField, List, ScrollView等
- **モダンな状態管理**: @State, @Binding, Observable (WWDC23スタイル)

## 他のTUIフレームワークとの違い

### React Ink
- **言語**: JavaScript/TypeScript向け
- **SwiftTUI**: Swift専用、SwiftUIと同じAPIパターン

### rensbreur/SwiftTUI
- **成熟度**: 実験的実装
- **SwiftTUI**: 実用レベル、231個のテストでカバー

### ncurses
- **API設計**: 命令的、低レベル
- **SwiftTUI**: 宣言的、高レベルSwiftUI風API

## 使用例

```swift
import SwiftTUI

struct HelloApp: View {
    @State private var name = ""
    
    var body: some View {
        VStack {
            Text("Hello, \(name)!")
                .foregroundColor(.green)
                .bold()
            
            TextField("Enter name", text: $name)
                .border()
        }
        .padding()
    }
}

// アプリケーションの起動
SwiftTUI.run(HelloApp())
```

## インストール

Swift Package Managerを使用：

```swift
dependencies: [
    .package(url: "https://github.com/bannzai/SwiftTUI.git", from: "1.0.0")
]
```

## 主要コンポーネント

### 基本View
- `Text`: テキスト表示
- `Button`: インタラクティブボタン
- `TextField`: テキスト入力
- `Spacer`: 空白スペース

### レイアウト
- `VStack`: 垂直スタック
- `HStack`: 水平スタック
- `List`: リスト表示
- `ScrollView`: スクロール可能領域

### インタラクティブ
- `Toggle`: ON/OFFスイッチ
- `Picker`: 選択UI
- `Slider`: 値調整
- `Alert`: 警告表示

### モディファイア
- `.padding()`: 余白追加
- `.border()`: 枠線
- `.background()`: 背景色
- `.foregroundColor()`: 文字色
- `.frame()`: サイズ指定

## アーキテクチャの特徴

### セルベースレンダリング
- ターミナルの各文字位置（セル）を個別管理
- 文字、前景色、背景色を正確に制御
- 差分更新による高速な再描画

### 日本語対応
- Unicode East Asian Width準拠
- 全角文字（漢字、ひらがな、カタカナ、絵文字）の正確な幅計算
- 表示崩れのない日本語UI

### 状態管理
- SwiftUI互換の@State、@Binding
- WWDC23スタイルのObservableパターン
- 自動的な再レンダリング

## ユースケース

- CLIツールのインタラクティブUI
- 開発者向けダッシュボード
- サーバー管理ツール
- 教育用プログラミング環境

## ライセンス

MIT License

## コントリビューション

プルリクエストを歓迎します。詳細は[CONTRIBUTING.md](../CONTRIBUTING.md)を参照してください。