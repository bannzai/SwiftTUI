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

**フェーズ4 - 追加コンポーネント**（ほぼ完了）
- [x] Toggle
- [x] Picker
- [ ] ~Sheet~ （TUIでの使用頻度が低いため実装見送り）
- [x] Alert
- [x] ProgressView
- [x] Slider

**フェーズ5 - 高度な状態管理**（完了）
- [x] Observable（WWDC23スタイル）
- [x] @Environment
- [x] EnvironmentValues

**重要な設計方針**：
1. **デュアルObservableサポート**：
   - SwiftTUI独自のObservable（全Swiftバージョン対応）
   - Swift標準の@Observable（Swift 5.9+、Observation framework）
   - 両方のObservableは同じ@Environmentで使用可能

2. **WWDC23 Observableパターンの採用**：
   - 手動通知: `didSet { notifyChange() }`（SwiftTUI Observable）
   - 自動追跡: `@Observable`マクロ（標準Observable）
   
3. **実装しない機能**（Combineベースの旧パターン）：
   - StateObject
   - Published
   - ObservableObject
   - ObservedObject
   - EnvironmentObject

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
- FocusManagerはCellRenderLoopと統合され、Tabキーナビゲーションを管理
  - `FocusManager.shared`がフォーカス可能なViewを追跡
  - TabキーイベントはFocusManagerが処理し、CellRenderLoop.scheduleRedraw()を呼び出す
- セルベースレンダリング：各セル（文字位置）に文字・前景色・背景色を独立して管理
  - `Cell`構造体: 個々のセルの情報を保持
  - `CellBuffer`: 画面全体のセルを2次元配列で管理
  - `CellLayoutView`プロトコル: セルベースレンダリングをサポートするView
  - HStack/VStackは`CellFlexStack`を使用して正しい背景色レンダリングを実現

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

## 既知の制限事項

### HStack内での表示問題
現在のレンダリングシステムには以下の制限があります：

1. **ボーダーの重複**
   - HStack内で隣接する要素にborder()を適用すると、境界線が重なって表示される
   - 原因: 各要素が独立してボーダーを描画し、bufferWriteが単純な上書き処理を行うため

2. **背景色の制限**
   - HStack内で複数の要素にbackground()を適用すると、最後の要素の背景色のみが表示される
   - 原因: 後の要素が前の要素の描画内容を上書きしてしまうため

3. **回避策**
   - 現時点では、HStack内でのborder()やbackground()の使用は制限される
   - 将来的にレイヤーベースのレンダリングシステムへの移行を検討中

### Tabキーナビゲーションの実装
現在のTabキーナビゲーションは以下のアーキテクチャで実装されています：

1. **ButtonLayoutManager**
   - ButtonLayoutViewインスタンスを永続化
   - 再レンダリング時にインスタンスが破棄されないように管理
   - Button IDごとにLayoutViewをキャッシュ
   - `prepareForRerender()`ですべてのボタンのフォーカス状態をリセット（複数のボタンがフォーカス状態になる問題を防ぐ）

2. **ライフサイクル管理**
   - CellRenderLoop.buildFrame()でFocusManagerとButtonLayoutManagerを準備
   - ButtonContainerがButtonLayoutManager経由でLayoutViewを取得
   - ViewRendererがButtonContainerを適切に処理
   - CellRenderLoop.buildFrame()の最後でFocusManager.finishRerendering()を呼び出し

3. **FocusManagerの再レンダリング処理**
   - `isRerendering`フラグで再レンダリング中の状態を管理
   - 再レンダリング中は最初のビューへの自動フォーカスをスキップ
   - `finishRerendering()`で保存されたフォーカスIDに基づいてフォーカスを復元
   - これにより、Tab循環時に複数のボタンがフォーカス状態になる問題を防ぐ

4. **注意点**
   - ButtonLayoutViewインスタンスはアプリケーションのライフサイクル全体で保持
   - メモリリークの可能性があるため、将来的には適切なクリーンアップが必要

### 最近の修正事項

#### EnvironmentWrapperの無限ループ修正（2025年7月）
- **問題**: `.environment()`モディファイアを使用するとプログラムがハングする
- **原因**: EnvironmentWrapperLayoutViewがmakeNode()内で毎回contentLayoutViewを作成していた
- **解決**: `ensureContentLayoutView()`メソッドを追加し、contentLayoutViewを一度だけ作成するように修正

#### PaddingLayoutViewのレイアウト計算修正（2025年7月）
- **問題**: VStackに`.padding()`を適用するとサイズが(w0×h0)になる
- **原因**: paint()メソッドで新しいノードを作成し、レイアウト計算をしていなかった
- **解決**: 
  - structからclassに変更し、calculatedNodeをキャッシュ
  - CellLayoutViewプロトコルを実装
  - レイアウト計算のフォールバック処理を追加

#### CellBorderLayoutViewのレンダリング修正（2025年7月）
- **問題**: `.border()`モディファイアを使用すると、子ビューのコンテンツが表示されない
- **原因**: 子ビューのサイズ計算とコンテンツのコピー処理が不適切だった
- **解決**:
  - 子ビューを一時バッファにレンダリングして実際のサイズを検出
  - コンテンツの境界に基づいてボーダーサイズを計算
  - 一時バッファから最終バッファの適切な位置にコンテンツをコピー
  - これにより`Text("Hello").border()`のような使用方法が正しく動作するようになった

#### CellBorderLayoutViewの追加修正（2025年7月）
- **問題**: `.padding().border()`の組み合わせで、ボーダー内のコンテンツが表示されない
- **原因**: 一時バッファ内のコンテンツが(0,0)から始まると仮定していたが、PaddingLayoutViewはオフセットを追加する
- **解決**:
  - 一時バッファ内の実際のコンテンツ位置(minX, minY)を検出
  - コンテンツをコピーする際、(0,0)からではなく実際の位置からコピー
  - これにより`Text("Hello").padding().border()`が正しく動作するようになった

### その他
- /tmpにスクリプトファイルを作らないでください
- ./tmp/に動作確認ようのスクリプトファイルを作りましょう
- ですが、まずは直接書くようにしてください。そうでないとコンソールにスクリプトの内容が出力されず、私がスクリプトの内容を確認できないからです

## ユニットテスト TODO

### 実装済みテスト（200テスト）
- [x] **TextTests** (7テスト) - 基本的なText表示、特殊文字、改行、文字列補間
- [x] **TextModifierTests** (6テスト) - padding、border、bold、foregroundColor、background、連鎖
- [x] **CompositeViewTests** (4テスト) - VStack、HStack、ネストされたスタック、スペーシング
- [x] **SpacerTests** (9テスト) - 基本動作、VStack/HStack内での拡張、複数Spacer、エッジケース
- [x] **TextFieldTests** (13テスト) - 基本表示、@Binding、プレースホルダー、ボーダー、レイアウト
- [x] **ButtonTests** (11テスト) - 基本表示、パディング、フォーカス、レイアウト、エッジケース
- [x] **ToggleTests** (15テスト) - ON/OFF表示、@Binding、複数トグル、フォーカス、エッジケース
- [x] **FrameModifierTests** (16テスト) - 幅制約、高さ制約、組み合わせ、レイアウト、エッジケース
- [x] **StateTests** (12テスト) - 初期値、複数@State、ネスト独立性、Binding変換、エッジケース
- [x] **BindingTests** (12テスト) - 親子同期、Binding.constant、カスタムBinding、型変換、エッジケース
- [x] **EnvironmentTests** (14テスト) - 環境値伝播、Observable統合、カスタムキー、エッジケース
- [x] **ForEachTests** (18テスト) - Range/Identifiable/KeyPath ForEach、ネスト、エッジケース
- [x] **ListTests** (12テスト) - 基本List表示、セパレーター、ForEach組み合わせ、エッジケース
- [x] **ScrollViewTests** (17テスト) - 基本スクロール、クリッピング、スクロールバー、エッジケース
- [x] **PickerTests** (15テスト) - ドロップダウン選択、ラベル表示、フォーカス、エッジケース
- [x] **SliderTests** (19テスト) - 値調整スライダー、範囲設定、@Binding、フォーカス、エッジケース

### Phase 1 - 基本コンポーネントのテスト
- [x] **ButtonTests** ✅ - Buttonビューのテスト
  - Labelの表示
  - フォーカス状態の表示（緑枠、選択色）
  - 非フォーカス状態の表示（白枠）
  - action実行の検証
  - VStack/HStack内での配置

### Phase 2 - Modifierのテスト  
- [x] **FrameModifierTests** ✅ - .frame()モディファイアのテスト
  - 幅制約の適用
  - 高さ制約の適用
  - 幅と高さ両方の制約
  - テキストの切り詰め表示
  - 他のモディファイアとの組み合わせ

### Phase 3 - State管理のテスト
- [x] **StateTests** ✅ - @Stateプロパティラッパーのテスト
  - 初期値の表示
  - 値の更新と再レンダリング
  - 複数の@Stateプロパティ
  - ネストされたView間での独立性

- [x] **BindingTests** ✅ - @Bindingのテスト
  - 親子間での値の同期
  - 双方向バインディング
  - Binding.constantの動作

- [x] **EnvironmentTests** ✅ - @Environmentのテスト
  - 環境値の取得
  - .environment()での値の設定
  - ネストされたView階層での伝播
  - カスタム環境値

### Phase 4 - 動的リストのテスト
- [x] **ForEachTests** ✅ - ForEachのテスト
  - Identifiable配列での動作
  - Rangeでの動作
  - KeyPath（id: \.self）での動作
  - 空の配列での動作

- [x] **ListTests** ✅ - Listビューのテスト
  - 項目の表示と自動区切り線
  - 空のリスト
  - 単一項目のリスト
  - ForEachとの組み合わせ

- [x] **ScrollViewTests** ✅ - ScrollViewのテスト
  - 基本スクロール機能（垂直・水平・両方向）
  - 固定ビューポート（3行×5文字）でのクリッピング
  - スクロールバー表示設定（showsIndicators）
  - 大きなコンテンツでの動作
  - ネストされたViewとVStack内配置
  - 既知の制限：.frame()モディファイア無視、グローバル状態共有

### Phase 5 - インタラクティブコンポーネントのテスト
- [x] **ToggleTests** ✅ - Toggleビューのテスト
  - OFF状態 [ ] とON状態 [✓] の表示
  - @Bindingでの状態管理（親子間バインディング）
  - ラベル表示と複数トグルの独立動作
  - フォーカス管理と複雑なレイアウト内での動作

- [x] **PickerTests** ✅ - Pickerビューのテスト
  - ドロップダウン選択UI（ラベル: [選択値 ▼]）
  - String型でのBasic表示とBinding管理
  - フォーカス状態の管理（TestRendererとの互換性問題あり）
  - 空選択肢、単一選択肢、長いラベル、特殊文字等のエッジケース
  - 注意：Int型Pickerでsignal 11クラッシュ、将来の調査が必要

- [ ] **SliderTests** - Sliderビューのテスト
  - 値の範囲と現在値
  - @Bindingでの値管理
  - ラベルとパーセンテージ表示

### Phase 6 - その他のコンポーネントのテスト
- [ ] **AlertTests** - Alertのテスト
  - .alert()モディファイアの動作
  - isPresentedバインディング
  - メッセージ表示

- [ ] **ProgressViewTests** - ProgressViewのテスト
  - 不確定進捗の表示（スピナー）
  - 確定進捗の表示（バー）
  - ラベル表示
