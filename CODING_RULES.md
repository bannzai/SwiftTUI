
## Swift Coding Rule
- 迷ったら標準的なルールにし違う
- インデントは 1tab=2space 
- 変数名は略さない
- class,struct,enum,actor,property,funcには説明のためのコメントを入れる
- class,struct,enum,actor には使用例を記述する
- 引数ラベルは工夫せずに受け取る変数をそのまま書く。func somehing(with value:) ではなく、 func something(value:) とする
- 本質的に同じものは変数名が一緒になる。例えば let item = Item()は良い。let greateItem = Item()はよくない。
- やむを得なくコーディングルールから逸脱する場合は、理由をコメントする。何を表しているのかを明確にする

## Bash Coding Rule
- set -euo pipefailをつける
- set -x もつける。ただし開発用途以外じゃないものはつけない
- help機能もつける
- 日本語でコマンドの使い方・コマンドの使用例を書く
- やむを得なくコーディングルールから逸脱する場合は、理由をコメントする。何を表しているのかを明確にする