# SwiftTUI C API詳細ガイド

このドキュメントでは、SwiftTUIで使用されているC由来のAPI、Darwin API、tty関連のシステムコールについて詳しく解説します。

## 目次

1. [はじめに](#はじめに)
2. [ターミナル制御API](#ターミナル制御api)
   - [termios構造体](#termios構造体)
   - [tcgetattr/tcsetattr](#tcgetattrtcsetattr)
   - [cfmakeraw](#cfmakeraw)
3. [ターミナルサイズ取得](#ターミナルサイズ取得)
   - [winsize構造体](#winsize構造体)
   - [ioctl](#ioctl)
4. [入出力関連](#入出力関連)
   - [read](#read)
   - [fputs](#fputs)
   - [fflush](#fflush)
5. [プロセス制御](#プロセス制御)
   - [signal](#signal)
   - [atexit](#atexit)
   - [exit](#exit)
6. [ファイルディスクリプタ](#ファイルディスクリプタ)

## はじめに

SwiftTUIは、ターミナル上でグラフィカルなUIを構築するため、多くの低レベルC APIを使用しています。これらのAPIは主に以下の目的で使用されます：

- ターミナルのrawモード設定（1文字ずつのリアルタイム入力）
- 画面サイズの取得
- キーボード入力の非同期処理
- 画面への効率的な出力
- プログラム終了時のクリーンアップ

## ターミナル制御API

### termios構造体

termios構造体は、ターミナルの動作を制御するための設定を保持します。

```c
struct termios {
    tcflag_t c_iflag;    // 入力モードフラグ
    tcflag_t c_oflag;    // 出力モードフラグ
    tcflag_t c_cflag;    // 制御モードフラグ
    tcflag_t c_lflag;    // ローカルモードフラグ
    cc_t c_cc[NCCS];     // 制御文字
    // ... その他のフィールド
}
```

#### 主要なフラグ

**c_iflag（入力モード）**
- `ICRNL`: CR（キャリッジリターン）をLF（改行）に変換
- `IXON`: Ctrl+S/Ctrl+Qによるフロー制御を有効化
- `ISTRIP`: 入力文字の8ビット目を削除
- `INLCR`: LFをCRに変換
- `IGNCR`: CRを無視

**c_oflag（出力モード）**
- `OPOST`: 出力処理を有効化
- `ONLCR`: LFをCR-LFに変換（改行時にカーソルを行頭に戻す）

**c_lflag（ローカルモード）**
- `ECHO`: 入力文字をエコーバック
- `ICANON`: 正規モード（行単位の入力）
- `ISIG`: シグナル文字（Ctrl+Cなど）の処理を有効化
- `IEXTEN`: 拡張入力処理を有効化

**c_cc（制御文字）**
- `VMIN`: 最小読み取り文字数
- `VTIME`: タイムアウト（0.1秒単位）

### tcgetattr/tcsetattr

現在のターミナル設定の取得と設定を行います。

```c
int tcgetattr(int fd, struct termios *termios_p);
int tcsetattr(int fd, int optional_actions, const struct termios *termios_p);
```

**パラメータ**
- `fd`: ファイルディスクリプタ（通常はSTDIN_FILENO）
- `optional_actions`: 
  - `TCSANOW`: 即座に設定を変更
  - `TCSADRAIN`: 出力を完了してから変更
  - `TCSAFLUSH`: 出力を完了し、入力をフラッシュしてから変更

**SwiftTUIでの使用**
```swift
// 現在の設定を保存
tcgetattr(STDIN_FILENO, &oldTerm)

// 新しい設定を適用
tcsetattr(STDIN_FILENO, TCSANOW, &raw)
```

**代替案と選択理由**
- **fcntl(fd, F_GETFL)**: ファイルフラグの取得は可能だが、termios構造体の詳細設定は取得できない
- **stty -g（シェルコマンド）**: 外部プロセス起動のオーバーヘッド
- **選択理由**: tcgetattrが最も包括的で効率的

### cfmakeraw

termios構造体をrawモード用に設定します。

```c
void cfmakeraw(struct termios *termios_p);
```

**rawモードの特徴**
- 1文字ずつ即座に読み取り（バッファリングなし）
- エコーなし（入力文字が画面に表示されない）
- 特殊文字処理なし（Ctrl+Cなども通常文字として受信）

**内部処理**
```c
raw.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON);
raw.c_oflag &= ~OPOST;
raw.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
raw.c_cflag &= ~(CSIZE | PARENB);
raw.c_cflag |= CS8;
raw.c_cc[VMIN] = 1;
raw.c_cc[VTIME] = 0;
```

**代替案と選択理由**
- **手動でフラグを設定**: より細かい制御が可能だが、複雑でエラーが起きやすい
- **部分的なrawモード**: 必要に応じて調整可能だが、完全なrawモードが必要
- **選択理由**: cfmakerawは標準的で確実、可読性が高い

## ターミナルサイズ取得

### winsize構造体

ターミナルのウィンドウサイズ情報を保持します。

```c
struct winsize {
    unsigned short ws_row;     // 行数（文字単位）
    unsigned short ws_col;     // 列数（文字単位）
    unsigned short ws_xpixel;  // 横幅（ピクセル単位、通常0）
    unsigned short ws_ypixel;  // 高さ（ピクセル単位、通常0）
};
```

### ioctl

I/O制御のシステムコールです。ターミナルサイズの取得に使用します。

```c
int ioctl(int fd, unsigned long request, ...);
```

**SwiftTUIでの使用**
```swift
var ws = winsize()
ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws)
let width = Float(ws.ws_col > 0 ? ws.ws_col : 80)
let height = Int(ws.ws_row > 0 ? ws.ws_row : 24)
```

**パラメータ**
- `STDOUT_FILENO`: 標準出力のファイルディスクリプタ（1）
- `TIOCGWINSZ`: "Terminal I/O Control Get WINdow SiZe"の略

**代替案と選択理由**
1. **getenv("COLUMNS") / getenv("LINES")**: 環境変数から取得
   - 欠点：リアルタイムの変更が反映されない、設定されていない場合がある
2. **tput cols / tput lines**: 外部コマンド実行
   - 欠点：プロセス起動のオーバーヘッド、移植性の問題
3. **ANSI escape sequence (CSI 18 t)**: ターミナルに問い合わせ
   - 欠点：非同期応答、すべてのターミナルでサポートされない
4. **tcgetwinsize() (POSIX.1-2024)**: 新しいPOSIX標準関数
   - 欠点：まだ広くサポートされていない
- **選択理由**: ioctlは最も確実で高速、POSIXで広くサポートされている

## 入出力関連

### read

ファイルディスクリプタからデータを読み取ります。

```c
ssize_t read(int fd, void *buf, size_t count);
```

**SwiftTUIでの使用**
```swift
var byte: UInt8 = 0
while read(fd, &byte, 1) == 1 {
    // 1バイトずつ処理
}
```

**代替案と選択理由**
- **FileHandle.readData(ofLength:)**: Foundationの高レベルAPI
  - 利点：Swiftらしい、例外処理
  - 欠点：オーバーヘッド、1バイト読み取りには非効率
- **InputStream**: ストリーム抽象化
  - 利点：バッファリング制御
  - 欠点：設定が複雑、rawモードとの相性が悪い
- **getchar()**: C標準ライブラリ
  - 欠点：内部バッファリングがrawモードと競合
- **選択理由**: read()は最も低レベルで確実、1バイト単位の制御が必要なTUIに最適

### fputs

文字列を出力します（改行なし）。

```c
int fputs(const char *s, FILE *stream);
```

**SwiftTUIでの使用**
```swift
fputs("\u{1B}[0m", stdout)  // ANSIリセットシーケンスを出力
```

**代替案と選択理由**
- **print()**: Swift標準だが、改行が追加される
- **write(STDOUT_FILENO, ...)**: より低レベルだが、文字列処理が面倒
- **FileHandle.standardOutput.write**: FoundationだがData変換が必要
- **選択理由**: fputsは改行なしで直接出力、シンプル

### fflush

出力ストリームのバッファを強制的に書き出します。

```c
int fflush(FILE *stream);
```

**なぜ必要か**
- printf/printは内部バッファに溜めて効率化している
- TUIでは即座に画面更新が必要
- 行バッファリング（改行で自動フラッシュ）では不十分

**代替案と選択理由**
1. **setbuf(stdout, NULL)**: バッファリング完全無効化
   - 欠点：すべての出力が非効率になる
2. **setvbuf(stdout, NULL, _IONBF, 0)**: 同上
3. **write(STDOUT_FILENO, ...)**: 低レベルI/O（バッファなし）
   - 欠点：文字列処理が面倒、エラー処理が複雑
4. **fsync(STDOUT_FILENO)**: ディスクまで同期
   - 欠点：ターミナル出力には過剰、パフォーマンス低下
- **選択理由**: 必要な時だけフラッシュする方が効率的で制御しやすい

## プロセス制御

### signal

シグナルハンドラーを登録します。

```c
void (*signal(int sig, void (*func)(int)))(int);
```

**SwiftTUIでの使用**
```swift
signal(SIGINT, c_sigint)  // Ctrl+C処理の登録
```

**代替案と選択理由**
- **sigaction()**: より詳細な制御が可能だが、複雑
- **DispatchSource.makeSignalSource**: Swiftらしいが、C関数の登録が必要な場合は結局signalが必要
- **Darwin.signal（Swiftラッパー）**: 実は同じAPI
- **選択理由**: signalはシンプルで十分、移植性が高い

注意：signal()はPOSIXで非推奨だが、単純な用途では問題なし。より堅牢にするならsigaction()を使用すべき。

### atexit

プログラム正常終了時に呼ばれる関数を登録します。

```c
int atexit(void (*func)(void));
```

**SwiftTUIでの使用**
```swift
atexit(c_restoreTTY)  // ターミナル設定復元の登録
```

**なぜC関数が必要か**
- atexit()はC関数ポインタを期待（void (*)(void)型）
- SwiftのクロージャはABI（Application Binary Interface）が異なる
- @_cdeclで明示的にC ABIに準拠させる必要がある

**代替案と選択理由**
- **deinit/デストラクタ**: Swiftオブジェクトの解放時実行だが、プロセス終了時の実行保証がない
- **NotificationCenter（アプリ終了通知）**: Cocoaアプリ限定、CLIツールでは信頼性が低い
- **選択理由**: atexitはPOSIX標準で最も確実

### exit

プロセスを終了させます。

```c
void exit(int status);
```

**exitの処理内容**
1. atexitで登録された関数を逆順で実行
2. すべてのストリームをフラッシュしてクローズ
3. tmpfile()で作成した一時ファイルを削除
4. _exit()を呼んでカーネルに制御を返す

**代替案と選択理由**
1. **_exit(0) / _Exit(0)**: 即座にプロセス終了
   - 欠点：クリーンアップ処理がスキップされる
   - 利点：シグナルハンドラ内では安全
2. **abort()**: 異常終了（SIGABRT送信）
   - 欠点：コアダンプ生成、異常終了扱い
3. **quick_exit()**: C11で追加された高速終了
   - 欠点：サポートが限定的、at_quick_exitの登録が必要
4. **return from main**: main関数からの戻り
   - 欠点：深いコールスタックからは使えない
- **選択理由**: exit()は標準的で、必要なクリーンアップを実行し、どこからでも呼び出せる

## ファイルディスクリプタ

UNIXシステムでファイルやデバイスを識別する整数値です。

**標準的なファイルディスクリプタ**
- `STDIN_FILENO` (0): 標準入力（キーボード）
- `STDOUT_FILENO` (1): 標準出力（画面）
- `STDERR_FILENO` (2): 標準エラー出力

SwiftTUIでは以下の用途で使用：
- `STDIN_FILENO`: キーボード入力の読み取り、rawモード設定
- `STDOUT_FILENO`: 画面への出力、ターミナルサイズ取得

## まとめ

SwiftTUIが使用するC APIは、すべてターミナルベースのUIを効率的に実装するために選択されています。各APIには代替案がありますが、以下の基準で選択されています：

1. **効率性**: 最小限のオーバーヘッドで動作
2. **移植性**: POSIX標準でmacOS/Linux両対応
3. **確実性**: エッジケースでも確実に動作
4. **シンプルさ**: 理解しやすく保守しやすい

これらのAPIを理解することで、SwiftTUIがどのようにターミナルを制御し、リアルタイムなUIを実現しているかが分かります。