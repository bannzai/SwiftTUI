# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリのコードを扱う際のガイダンスを提供します。

## プロジェクトビジョン

SwiftTUIは、ReactのInkに相当するSwift向けライブラリです。InkがReact開発者に馴染みのあるReactパターンでTUIを構築できるようにするのと同様に、SwiftTUIはSwift開発者がSwiftUIライクな構文でターミナルインターフェースを作成できるようにします。

## コア哲学

### 1. SwiftUI互換API
- SwiftUIのAPIパターンに**必ず**従う
- Viewは`View`プロトコルに準拠したstruct
- 全てのViewは`var body: some View`計算プロパティを実装
- ViewModifierはメソッドチェインで適用（`.padding()`、`.border()`など）
- 手動のrender呼び出しは**不要** - フレームワークが内部で全てのレンダリングを処理

### 2. 宣言的、命令的ではない
- ユーザーはUIが「どのように見えるべきか」を記述し、「どうレンダリングするか」は記述しない
- 状態変更は自動的に再レンダリングをトリガー
- ユーザーコードでの手動バッファ操作や座標計算は不要

### 3. SwiftUI開発者にとって馴染みやすい
- SwiftUI開発者が最小限の学習コストでSwiftTUIを使えるべき
- 同じメンタルモデル：Views、Modifiers、State管理
- 同じパターン：`@State`、`@Binding`、`@ObservedObject`（実装時）

## 開発ガイドライン

### API設計原則

```swift
// ✅ 良い例 - SwiftUIライク
struct ContentView: View {
    @State private var name = ""
    
    var body: some View {
        VStack {
            Text("Hello, \(name)!")
                .foregroundColor(.green)
                .bold()
            
            TextField("Enter name", text: $name)
                .border()
                .padding()
        }
    }
}

// ❌ 悪い例 - 現在の実装（リファクタリング対象）
struct ContentView: LayoutView {
    func makeNode() -> YogaNode { ... }
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) { ... }
    func render(into buffer: inout [String]) { ... }
}
```

### 実装戦略

1. **Viewプロトコルの進化**
   - 現在の`render(into:)`を持つ`LayoutView`から、SwiftUIスタイルの`body`を持つ`View`へ移行
   - Yoga実装の詳細を完全に隠蔽
   - View階層に基づく自動レイアウト計算

2. **ViewModifierプロトコル**
   - 適切なViewModifierプロトコルの実装
   - 全てのmodifierでメソッドチェインを有効化
   - Modifierは`some View`を返し、具象型ではない

3. **レンダリングパイプライン**
   - ユーザーコードはViewの宣言のみ
   - フレームワークが処理：
     - レイアウト計算（Yoga経由）
     - バッファ管理
     - 差分レンダリング
     - ターミナル操作

### コンポーネントロードマップ

**フェーズ1 - コアコンポーネント**（完了）
- [x] Text
- [x] VStack、HStack（spacing対応）
- [x] Spacer
- [x] TextField（@Binding対応）
- [x] Button（フォーカス管理対応）

**フェーズ2 - 必須Modifier**（完了）
- [x] .padding()（方向指定対応）
- [x] .border()
- [x] .background()
- [x] .foregroundColor()
- [x] .frame(width:height:)
- [x] .bold()

**フェーズ3 - 高度な機能**（完了）
- [x] @State プロパティラッパー
- [x] @Binding サポート
- [x] ForEach（Identifiable、KeyPath、Range対応）
- [x] ScrollView（垂直・水平スクロール対応）
- [x] List（自動セパレーター付き）

**フェーズ4 - 追加コンポーネント**（計画中）
- [ ] Toggle
- [ ] Picker
- [ ] Sheet
- [ ] Alert
- [ ] ProgressView
- [ ] Slider

**フェーズ5 - 高度な状態管理**（計画中）
- [ ] @ObservedObject
- [ ] @StateObject
- [ ] @EnvironmentObject
- [ ] @Environment

**フェーズ6 - 追加Modifier**（計画中）
- [ ] .opacity()
- [ ] .disabled()
- [ ] .hidden()
- [ ] .overlay()
- [ ] .clipShape()
- [ ] .animation()

## 技術アーキテクチャ（内部）

### 現在の状態（リファクタリング対象）
- 明示的な`render`と`paint`メソッドを持つ`LayoutView`プロトコル
- ViewコードでのYogaノードの直接操作
- 手動バッファ管理

### 目標状態
- `body: some View`を持つ純粋な`View`プロトコル
- 内部レイアウトエンジンにカプセル化されたYoga
- 自動レンダリングパイプライン
- 最適なパフォーマンスのためのView差分検出

### 移行パス
1. 既存の`LayoutView`と並行して新しい`View`プロトコルを作成
2. 新APIを既存エンジンにブリッジする内部レンダラーを実装
3. 全コンポーネントを新APIに段階的に移行
4. 古い`LayoutView`システムを非推奨化して削除

## 使用例（目標API）

### Hello World
```swift
import SwiftTUI

struct HelloApp: View {
    var body: some View {
        Text("Hello, Terminal!")
            .foregroundColor(.cyan)
            .padding()
            .border()
    }
}

// main.swiftで
SwiftTUI.run(HelloApp())
```

### インタラクティブフォーム（現在動作中）
```swift
struct FormView: View {
    @State private var username = ""
    @State private var age = ""
    
    var body: some View {
        VStack(spacing: 1) {
            Text("ユーザー登録")
                .bold()
                .padding(.bottom, 2)
            
            HStack {
                Text("ユーザー名:")
                TextField("ユーザー名を入力", text: $username)
                    .frame(width: 20)
            }
            
            HStack {
                Text("年齢:")
                TextField("年齢を入力", text: $age)
                    .frame(width: 10)
            }
            
            Button("送信") {
                print("ユーザー名: \(username), 年齢: \(age)")
            }
            .padding(.top, 2)
        }
        .padding()
        .border()
    }
}

// 実行方法：swift run InteractiveFormTest
```

## React Inkとの比較

```javascript
// React Ink
import React, {useState} from 'react';
import {render, Text, Box, TextInput} from 'ink';

const App = () => {
    const [name, setName] = useState('');
    
    return (
        <Box flexDirection="column" borderStyle="single">
            <Text>Hello, {name}!</Text>
            <TextInput value={name} onChange={setName} />
        </Box>
    );
};

render(<App />);
```

```swift
// SwiftTUI（目標）
import SwiftTUI

struct App: View {
    @State private var name = ""
    
    var body: some View {
        VStack {
            Text("Hello, \(name)!")
            TextField("名前を入力", text: $name)
        }
        .border()
    }
}

SwiftTUI.run(App())
```

## 内部実装メモ

- YogaはレイアウトCalculateに内部的に使用されるが、公開APIには**決して**露出しない
- ターミナル操作はANSIエスケープシーケンスを使用
- 差分レンダリングでパフォーマンスを最適化
- イベントループがキーボード入力と状態更新を処理

## テストガイドライン

- 内部実装ではなく、公開APIの振る舞いをテスト
- API設計でSwiftUI互換性を確保
- 大規模なView階層のレンダリングのパフォーマンステスト
- ターミナル出力の統合テスト

## してはいけないこと

- 公開APIでYoga型を露出する
- ユーザーにrenderメソッドの呼び出しを要求する
- 命令的パターンと宣言的パターンを混在させる
- 強い正当性なしにSwiftUIに存在しないAPIを作成する