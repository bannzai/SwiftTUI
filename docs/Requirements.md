# SwiftTUI Re-architecture要件定義

## 背景

SwiftTUIは2023年から開発が開始され、SwiftUIライクなAPIでターミナルUIを構築できるフレームワークとして成長してきました。しかし、開発が進むにつれて、現在のアーキテクチャにいくつかの課題が顕在化しています。

## 現状の課題

### 1. 2層アーキテクチャの複雑性

現在の実装では、以下の変換フローが存在します：

```
[View] → [ViewRenderer] → [LayoutView] → [CellRenderLoop] → [Terminal]
```

**問題点:**
- 各層での変換コストが発生
- 新しいViewの追加時に複数ファイルの変更が必要
- デバッグが困難（どの層で問題が発生しているか特定しづらい）
- メンテナンスコストの増大

### 2. 型安全性の欠如

ViewRenderer.swiftでの型判定：

```swift
let typeName = String(describing: type(of: view))
if typeName.hasPrefix("ModifiedContent<") {
    return renderModifiedContent(view)
}
```

**問題点:**
- 文字列ベースの型判定は脆弱
- コンパイル時の型チェックが効かない
- リファクタリング時にバグが混入しやすい
- Swift 6などの新バージョンで動作が変わる可能性

### 3. 内部実装の露出

各Viewが内部実装を保持する必要：

```swift
struct Text: View {
    internal var _layoutView: TextLayoutView { ... }
}
```

**問題点:**
- カプセル化の破壊
- 実装詳細がpublicインターフェースに漏れる
- APIの進化が困難

### 4. 拡張性の制限

新しいViewやモディファイアの追加手順：
1. Viewプロトコル準拠の構造体作成
2. 対応するLayoutView実装
3. ViewRendererへの型判定追加
4. テストの作成

**問題点:**
- 最低3つのファイルを変更する必要
- ボイラープレートコードの増加
- 貢献者にとって参入障壁が高い

## 新アーキテクチャの要件

### 必須要件

#### R1: 単一層View実装
- Viewプロトコルがレンダリングロジックもカプセル化
- 中間層（LayoutView）の完全廃止
- ViewからRenderNodeへの直接変換

#### R2: 型安全な設計
- プロトコル準拠による型判定
- ジェネリクスとassociatedtypeの活用
- 文字列ベースの型判定を排除

#### R3: 後方互換性
- 既存のpublic APIを維持
- 段階的な移行パスの提供
- deprecation期間の設定（最低2マイナーバージョン）

### 機能要件

#### F1: レンダリングシステム
- Nodeベースのビューグラフ実装
- 効率的なdiffingアルゴリズム
- セルベースレンダリングの継続（日本語対応のため必須）
- 部分更新による最適化

#### F2: レイアウトエンジン
- Yogaの内部化（公開APIから完全に隠蔽）
- SwiftUIライクなレイアウトモディファイア
- カスタムレイアウトのサポート
- Auto Layoutに近い制約システム

#### F3: 状態管理
- 現在のObservableパターン維持
- 自動的な依存関係追跡
- @Environmentの拡張
- カスタム環境値の容易な追加

#### F4: イベント処理
- 統一されたイベントパイプライン
- フォーカス管理の改善
- カスタムジェスチャーのサポート
- 非同期イベント処理

### 非機能要件

#### N1: パフォーマンス
- 現在のレンダリング速度を維持または向上
- メモリ使用量を20%削減
- 初回レンダリング時間を50%短縮
- 大規模View階層（1000+ノード）でも60fps維持

#### N2: 開発体験
- 新しいViewの追加が単一ファイルで完結
- 明確なエラーメッセージ
- 豊富なデバッグ情報
- プロトコル指向による拡張性

#### N3: テスタビリティ
- 単体テストの容易性向上
- モックオブジェクトの作成が簡単
- レンダリング結果の検証が可能
- パフォーマンステストの自動化

#### N4: ドキュメント
- APIドキュメントの自動生成
- 移行ガイドの提供
- アーキテクチャ図の維持
- サンプルコードの充実

## 成功基準

1. **技術的成功基準**
   - 全ての既存テスト（231個）がパス
   - パフォーマンスベンチマークで改善を確認
   - 新規View追加が30分以内で可能

2. **プロジェクト成功基準**
   - 既存ユーザーからの肯定的フィードバック
   - コントリビューターの増加
   - 新機能追加速度の向上

## 制約事項

1. **技術的制約**
   - Swift 5.5以上のサポート継続
   - macOS 11.0以上のサポート
   - Yogaライブラリへの依存継続（内部実装として）

2. **リソース制約**
   - 開発期間：16週間
   - 既存機能の保守と並行開発
   - ドキュメント作成を含む

## リスクと対策

1. **移行リスク**
   - リスク：既存ユーザーのコードが動作しない
   - 対策：包括的な移行ツールの提供

2. **パフォーマンスリスク**
   - リスク：新アーキテクチャで速度低下
   - 対策：早期のベンチマーク実施

3. **複雑性リスク**
   - リスク：新設計が逆に複雑になる
   - 対策：プロトタイプによる検証