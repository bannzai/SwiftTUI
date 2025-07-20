# SwiftTUI開発メモ

このドキュメントは、SwiftTUIの開発過程での技術的な発見、設計判断、学びなどを記録するためのメモです。

## 設計判断の記録

### 2025-01-20: Re-architecture開始の決定

**背景:**
- 現在の2層アーキテクチャ（View → LayoutView）の複雑性が開発速度を低下させている
- 新しいViewの追加に3つ以上のファイル変更が必要
- 型安全性の欠如（文字列ベースの型判定）

**判断:**
- rensbreur/SwiftTUIの単一層設計を参考にアーキテクチャを再設計
- RenderNodeベースの新システムへ移行
- 段階的な移行で既存ユーザーへの影響を最小化

**根拠:**
- 型安全性の向上により、コンパイル時エラーの早期発見が可能
- 開発者体験の向上（新Viewの追加が簡単に）
- メンテナンス性の向上

### セルベースレンダリングの継続

**判断:** 新アーキテクチャでもセルベースレンダリングを維持

**理由:**
1. **日本語対応**: East Asian Width対応で必須
2. **背景色の正確な描画**: 文字列ベースでは不可能
3. **差分更新の効率化**: セル単位での更新が可能

**実装詳細:**
- CellBufferは現行のまま使用
- RenderNodeがCellBufferに直接描画
- isContinuationフラグで2幅文字を適切に処理

### Yogaレイアウトエンジンの扱い

**判断:** 内部実装として継続使用、公開APIからは完全に隠蔽

**理由:**
1. **成熟したレイアウトエンジン**: Flexboxアルゴリズムの再実装は非効率
2. **パフォーマンス**: C++実装で高速
3. **将来性**: 必要に応じて別のエンジンに置き換え可能

**実装方針:**
- RenderNode内部でのみYogaNodeを使用
- SwiftUIライクなAPIでラップ
- レイアウト計算の詳細を隠蔽

## 技術的な発見

### 2025-01-20: ViewGraphのキャッシング戦略

**発見:** ObjectIdentifierを使用したノード識別が効果的

```swift
// ノードの識別
let nodeId = ObjectIdentifier(view)
previousNodes[nodeId] = renderNode
```

**利点:**
- Viewインスタンスの一意性を保証
- 高速なルックアップ
- メモリ効率的

### RenderNode設計でのトレードオフ

**クラス vs 構造体:**

選択: **クラス**

理由:
1. 参照セマンティクスで親子関係の管理が容易
2. 大規模階層での値型コピーのオーバーヘッド回避
3. ノード間の循環参照はweak参照で解決可能

### 型消去の回避戦略

**問題:** AnyViewの多用はパフォーマンス低下を招く

**解決策:**
```swift
// 型消去を避けるジェネリック設計
func renderNode<V: View>(view: V) -> RenderNode {
    // 具体的な型情報を保持
}
```

**効果:**
- 型情報の保持によるコンパイラ最適化
- 動的ディスパッチの削減

## パフォーマンス関連の発見

### 差分計算の最適化

**発見:** 構造的な差分より属性の差分が多い

**対策:**
1. 属性変更の高速パス実装
2. フレーム変更時のみ再レイアウト
3. 子ノードの差分は遅延評価

### メモリ使用量の分析

**現状:**
- LayoutView: 各Viewが独立したYogaNodeを保持
- 深い階層でメモリ使用量が増大

**改善案:**
- RenderNode: YogaNodeを一時的に生成・破棄
- レイアウト結果のみ保持
- メモリプールの活用

## 実装上の課題と解決策

### ButtonLayoutManagerの扱い

**課題:** フォーカス管理のために永続化が必要

**現在の解決策:** シングルトンパターン

**新アーキテクチャでの方針:**
- ViewGraphがフォーカス状態を管理
- RenderContextで状態を伝播
- ButtonLayoutManagerを廃止

### 非同期更新の処理

**課題:** キーボード入力と再レンダリングの競合

**解決策:**
1. 更新キューの実装
2. バッチ処理で効率化
3. 優先度付きレンダリング

## 今後の課題

### 短期的課題（Phase 1-2で対応）

1. **プロトタイプの検証**
   - TextRenderNodeで基本実装を検証
   - パフォーマンス比較
   - API使用感の確認

2. **テスト戦略**
   - 新旧システムの並行テスト
   - 視覚的回帰テスト
   - パフォーマンステスト自動化

### 中期的課題（Phase 3-4で対応）

1. **アニメーション対応**
   - フレーム間の補間
   - タイミング関数
   - 非同期アニメーション

2. **カスタムレイアウト**
   - Layoutプロトコルの設計
   - GeometryReaderの実装
   - 制約ベースレイアウト

### 長期的課題（将来バージョン）

1. **AsyncSequenceサポート**
   ```swift
   struct AsyncDataView: View {
       let stream: AsyncSequence
       var body: some View {
           ForEach(stream) { item in
               Text(item.description)
           }
       }
   }
   ```

2. **プラグインシステム**
   - カスタムレンダラー
   - 外部ライブラリ統合
   - テーマシステム

3. **マルチプラットフォーム**
   - Windows Terminal対応
   - Web Assembly対応
   - SSH経由のリモートUI

## 参考リンク

### 技術資料
- [SwiftUI's diffing algorithm](https://rensbr.eu/blog/swiftui-diffing/)
- [The SwiftUI render loop](https://rensbr.eu/blog/swiftui-render-loop/)
- [Yoga Layout Engine](https://yogalayout.com/)

### 関連プロジェクト
- [rensbreur/SwiftTUI](https://github.com/rensbreur/SwiftTUI)
- [React Ink](https://github.com/vadimdemedes/ink)
- [Blessed](https://github.com/chjj/blessed)

## コードスニペット集

### RenderNode実装パターン

```swift
// 基本的なRenderNode実装
class CustomRenderNode: RenderNode {
    override func renderContent(into buffer: inout CellBuffer) {
        // レンダリングロジック
    }
    
    override func layout(constraints: LayoutConstraints) {
        // カスタムレイアウト
        super.layout(constraints: constraints)
    }
}
```

### 効率的な差分計算

```swift
// 子ノードの差分計算
func diffChildren(old: [RenderNode], new: [RenderNode]) -> [ChildPatch] {
    // LCSアルゴリズムを使用
    let commonSubsequence = longestCommonSubsequence(old, new)
    // 差分を計算
    return calculatePatches(from: commonSubsequence)
}
```

## 開発環境のTips

### デバッグ方法

1. **RenderNode可視化**
   ```swift
   // デバッグモードでノードツリーを出力
   if DEBUG {
       rootNode.printTree()
   }
   ```

2. **差分ログ**
   ```swift
   // 差分を可視化
   patches.forEach { patch in
       print("Patch: \(patch.description)")
   }
   ```

### パフォーマンス計測

```swift
// レンダリング時間の計測
let start = CFAbsoluteTimeGetCurrent()
viewGraph.update(with: rootView)
let elapsed = CFAbsoluteTimeGetCurrent() - start
print("Render time: \(elapsed * 1000)ms")
```

## 決定事項の記録

### 命名規則

- RenderNode系: `〜RenderNode`
- 内部プロトコル: `_〜Protocol`
- 環境値: `〜Key`

### バージョニング

- 新アーキテクチャ: v2.0.0
- 移行期間: v1.x系を6ヶ月サポート
- deprecation: 2段階で実施

### リリース方針

1. v2.0.0-beta.1: Phase 2完了時
2. v2.0.0-beta.2: Phase 3完了時
3. v2.0.0-rc.1: Phase 4完了時
4. v2.0.0: Phase 5完了時