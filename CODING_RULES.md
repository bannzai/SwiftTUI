
## Swift Coding Rule

重要: **Swift Coding Rule** の定める話はSwiftUIのインタフェースの話ではなくて、RenderLoopや内部のコードの話です。なので、SwiftTUIの公開するインタフェースであるSwiftUIのインタフェースは、SwiftUIのインタフェースに近づけてください

- 迷ったら標準的なルールに従う
- インデントは 1tab=2space 
- 変数名は略さない
- class,struct,enum,actor,property,funcには説明のためのコメントを入れる
- class,struct,enum,actor には使用例を記述する
- 引数ラベルは工夫せずに受け取る変数をそのまま書く。func somehing(with value:) ではなく、 func something(value:) とする
- 本質的に同じものは変数名が一緒になる。例えば let item = Item()は良い。let greateItem = Item()はよくない。
- やむを得なくコーディングルールから逸脱する場合は、理由をコメントする。何を表しているのかを明確にする

### コーディングスタイル詳細

1. **スペーシングの統一**
   - 型注釈のコロン後にスペース追加：`var codes:[String]=[]` → `var codes: [String] = []`
   - タプル型注釈のスペース追加：`origin:(x:Int,y:Int)` → `origin: (x: Int, y: Int)`
   - 演算子の前後にスペース追加：`s=self` → `s = self`
   - パラメータラベル後のスペース追加：`into:&buf` → `into: &buf`

2. **関数定義の改善**
   - 戻り値型注釈のスペース追加：`->Int{` → `-> Int {`
   - クロージャ型のスペース追加：`@escaping()->V` → `@escaping () -> V`

3. **コード構造の改善**
   - セミコロンで区切られた複数文を別々の行に分割
   - 一行のメソッドを複数行に展開し、可読性を向上
   - guard文は複数行で記述（guard ... else { return } の形式）

### 2025年1月の修正実績

以下のファイルがこれらのコーディングスタイルに準拠するよう修正されました：

- `Runtime/RenderLoop.swift` - レンダリングループのコアロジック
- `Primitives/LegacyText.swift` - テキスト表示の基本実装
- `Modifiers/Padding.swift` - パディングモディファイア
- `Modifiers/Border.swift` - ボーダーモディファイア
- `Layout/YogaNode.swift` - Yogaレイアウトエンジンのラッパー

## Bash Coding Rule
- set -euo pipefailをつける
- set -x もつける。ただし開発用途以外じゃないものはつけない
- help機能もつける
- 日本語でコマンドの使い方・コマンドの使用例を書く
- やむを得なくコーディングルールから逸脱する場合は、理由をコメントする。何を表しているのかを明確にする
