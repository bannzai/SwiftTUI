# LTスライドについて

SwiftTUIのLT（ライトニングトーク）用スライドです。
情報量少なめで、ペラペラめくれるライトな構成にしています。

## スライドの使い方

`PITCHME.md`はMarp形式のプレゼンテーションファイルです（GitPitchの命名規則に従っています）。

### 表示方法

1. **VSCode + Marp拡張機能**（推奨）
   - VSCodeに[Marp for VS Code](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode)をインストール
   - `PITCHME.md`を開いて、右上のプレビューアイコンをクリック

2. **Marp CLI**
   ```bash
   # インストール
   npm install -g @marp-team/marp-cli
   
   # HTMLに変換
   marp PITCHME.md -o slides.html
   
   # PDFに変換
   marp PITCHME.md -o slides.pdf
   
   # サーバーモードで表示
   marp -s PITCHME.md
   ```

3. **オンラインビューア**
   - [Marp Web](https://web.marp.app/)にファイルをドラッグ&ドロップ

## デモのスクリーンショット撮影

デモアプリを実行してスクリーンショットを撮影：

```bash
# デモアプリの実行
cd Examples/DemoForLT
swift run

# スクリーンショットはOSの機能で撮影
# macOS: Cmd + Shift + 4
```

## スライドのカスタマイズ

- フォントサイズを変更したい場合は、各スライドに`<!-- _class: lead -->`を追加
- 背景色を変更したい場合は、`<!-- _backgroundColor: #123 -->`を追加
- 画像を追加する場合は、`![](path/to/image.png)`を使用

## スクリーンショット用デモコマンド

各デモを個別に実行：

```bash
# Hello Worldデモ
swift run --package-path Examples/HelloWorld

# インタラクティブフォームデモ  
swift run --package-path Examples/InteractiveFormTest

# リストデモ
swift run --package-path Examples/ListTest
```