/// InputLoop：ターミナルのキーボード入力を監視・処理するモジュール
///
/// キーボード入力処理の核心となる型です。
/// 主な機能：
/// - ターミナルのrawモード設定
/// - 非同期キーボード入力の監視
/// - ESCシーケンスの解析（矢印キーなど）
/// - キーイベントへの変換
///
/// TUI初心者向け解説：
/// - 通常、ターミナルは行単位で入力を処理（Enterで確定）
/// - TUIでは1文字ずつリアルタイムで処理が必要
/// - そのために「rawモード」という特殊な設定を使用
///
/// rawモードとは：
/// - 文字を1つずつ即座に受け取る
/// - Ctrl+Cなどの特殊キーも直接受け取る
/// - echoがオフ（入力文字が画面に表示されない）

import Foundation
import Darwin        // termios, signal
// Darwin: macOS/iOS向けのシステムフレームワーク
// POSIX準拠のC APIを提供（Linux版では<termios.h>、<signal.h>をインポート）

enum InputLoop {

  // ── internal state ────────────────────────────────────────────────
  /// 非同期読み取りソース
  ///
  /// DispatchSourceReadは、ファイルディスクリプタから
  /// データが読み取り可能になったときに通知するオブジェクト。
  /// キーボード入力を非同期で監視するために使用。
  private static var src: DispatchSourceRead?
  
  /// 元のターミナル設定のバックアップ
  ///
  /// termios構造体には、ターミナルの詳細な設定が含まれる：
  /// - c_iflag: 入力モード（ICRNL: CR→LF変換、IXON: Ctrl+S/Q制御など）
  /// - c_oflag: 出力モード（OPOST: 出力処理、ONLCR: LF→CRLF変換など）
  /// - c_cflag: 制御モード（ボーレート、データビット数など）
  /// - c_lflag: ローカルモード（ECHO: エコー、ICANON: 正規モードなど）
  /// - c_cc: 制御文字（VMIN: 最小読み取り文字数、VTIME: タイムアウトなど）
  /// プログラム終了時に元の設定に戻すため保存。
  ///
  /// 代替案：
  /// - Foundation.Process: 新しいプロセスを起動する際の制御には便利だが、
  ///   現在実行中のプロセスのtty制御には不向き
  /// - pty（疑似端末）: 仮想端末を作成できるが、オーバーヘッドが大きく、
  ///   単純なキーボード入力処理には過剰
  /// 選択理由：termiosは最も直接的で軽量、POSIXで標準化されている
  private static var oldTerm = termios()
  
  /// 標準入力のファイルディスクリプタ
  ///
  /// STDIN_FILENO = 0
  /// ファイルディスクリプタはUNIXでファイルやデバイスを
  /// 識別する整数。0は標準入力（キーボード）を表す。
  private static let fd = STDIN_FILENO
  
  /// 現在のイベントハンドラー
  ///
  /// キーボードイベントが発生したときに呼び出される
  /// クロージャを保存。ViewやButtonなどが登録する。
  private static var currentEventHandler: ((KeyboardEvent) -> Void)?

  // ── public ────────────────────────────────────────────────────────
  /// キーボード入力監視を開始
  ///
  /// アプリケーション起動時にRenderLoopから呼ばれる。
  /// ターミナルをrawモードに設定し、キーボード入力の
  /// 非同期監視を開始する。
  ///
  /// - Parameter eventHandler: キーイベント発生時のコールバック
  static func start(eventHandler: @escaping (KeyboardEvent) -> Void) {
    currentEventHandler = eventHandler

    // ① raw-mode へ切り替え
    // tcgetattr: 現在のターミナル設定を取得
    // 戻り値: 成功時0、失敗時-1（errno設定）
    // &oldTerm: 設定を保存する構造体へのポインタ
    //
    // 代替案：
    // - fcntl(fd, F_GETFL): ファイルフラグの取得は可能だが、
    ///  termios構造体の詳細設定は取得できない
    // - stty -g（シェルコマンド）: 外部プロセス起動のオーバーヘッド
    // 選択理由：tcgetattrが最も包括的で効率的
    tcgetattr(fd, &oldTerm)
    
    // cfmakeraw: termios構造体をrawモード用に設定
    // rawモードの特徴：
    // - 1文字ずつ即座に読み取り（バッファリングなし）
    // - エコーなし（入力文字が画面に表示されない）
    // - 特殊文字処理なし（Ctrl+Cなども通常文字として受信）
    //
    // cfmakerawが内部で行う処理：
    // - raw.c_iflag &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON)
    // - raw.c_oflag &= ~OPOST
    // - raw.c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN)
    // - raw.c_cflag &= ~(CSIZE | PARENB)
    // - raw.c_cflag |= CS8
    // - raw.c_cc[VMIN] = 1
    // - raw.c_cc[VTIME] = 0
    //
    // 代替案：
    // - 手動でフラグを設定: より細かい制御が可能だが、
    //   複雑でエラーが起きやすい
    // - 部分的なrawモード: 例えばICANONのみオフにするなど、
    //   必要に応じて調整可能だが、完全なrawモードが必要
    // 選択理由：cfmakerawは標準的で確実、可読性が高い
    var raw = oldTerm; cfmakeraw(&raw)
    
    // tcsetattr: 新しい設定を適用
    // TCSANOW: 即座に設定を変更
    tcsetattr(fd, TCSANOW, &raw)

    // ② 終了シグナルをフック
    // プログラムが終了する際、必ずターミナル設定を
    // 元に戻す必要がある。そうしないとターミナルが
    // 使えない状態になってしまう。
    
    // atexit: プログラム正常終了時に呼ばれる関数を登録
    // c_restoreTTY: C言語から呼び出せる関数（後述）
    //
    // 代替案：
    // - deinit/デストラクタ: Swiftオブジェクトの解放時実行だが、
    //   プロセス終了時の実行保証がない
    // - NotificationCenter（アプリ終了通知）: Cocoaアプリ限定、
    //   CLIツールでは信頼性が低い
    // 選択理由：atexitはPOSIX標準で最も確実
    atexit(c_restoreTTY)
    
    // signal: シグナルハンドラーを登録
    // SIGINT: Ctrl+Cが押されたときのシグナル（番号2）
    // c_sigint: シグナル受信時の処理関数
    //
    // 代替案：
    // - sigaction(): より詳細な制御が可能だが、複雑
    // - DispatchSource.makeSignalSource: Swiftらしいが、
    //   C関数の登録が必要な場合は結局signalが必要
    // - Darwin.signal（Swiftラッパー）: 実は同じAPI
    // 選択理由：signalはシンプルで十分、移植性が高い
    //
    // 注意：signal()はPOSIXで非推奨だが、単純な用途では問題なし
    // より堅牢にするならsigaction()を使用すべき
    signal(SIGINT, c_sigint)

    // ③ 非同期 read の設定
    // GCD（Grand Central Dispatch）を使って
    // キーボード入力を非同期で監視する。
    
    // 専用のDispatchQueueを作成
    // label: デバッグ時に識別しやすい名前
    let q = DispatchQueue(label: "SwiftTUI.Input")
    
    // DispatchSourceReadを作成
    // fileDescriptor: 監視対象（標準入力）
    // queue: イベント処理を実行するキュー
    src = DispatchSource.makeReadSource(fileDescriptor: fd, queue: q)
    
    // データが読み取り可能になったときの処理
    src?.setEventHandler {
      var byte: UInt8 = 0
      
      // read(): UNIXシステムコール
      // fd: 読み取り元（標準入力）
      // &byte: 読み取ったデータを格納する変数
      // 1: 1バイトずつ読み取り
      // 戻り値: 読み取ったバイト数（エラー時は-1、errno設定）
      //
      // 代替案：
      // - FileHandle.readData(ofLength:): Foundationの高レベルAPI
      //   利点：Swiftらしい、例外処理
      //   欠点：オーバーヘッド、1バイト読み取りには非効率
      // - InputStream: ストリーム抽象化
      //   利点：バッファリング制御
      //   欠点：設定が複雑、rawモードとの相性が悪い
      // - getchar(): C標準ライブラリ
      //   欠点：内部バッファリングがrawモードと競合
      // 選択理由：read()は最も低レベルで確実、1バイト単位の
      // 制御が必要なTUIに最適、DispatchSourceとの相性も良い
      while read(fd, &byte, 1) == 1 {
        // translate: バイトをKeyboardEventに変換
        // 通常の文字、特殊キー、ESCシーケンスを解析
        if let ev = Self.translate(byte: byte) { 
          eventHandler(ev) 
        }
      }
    }
    
    // 監視を開始
    // resume()を呼ぶまでイベントは発生しない
    src?.resume()
  }

  /// キーボード入力監視を停止
  ///
  /// RenderLoop.shutdownから呼ばれる。
  /// 非同期監視を停止し、ターミナル設定を元に戻す。
  ///
  /// 重要：必ず呼ばれる必要がある
  /// rawモードのままプログラムが終了すると、
  /// ターミナルが使えなくなってしまう。
  static func stop() {
    // DispatchSourceをキャンセル
    // これ以降、キーボードイベントは発生しない
    src?.cancel()
    
    // ターミナル設定を元に戻す
    restoreTTY()
  }

  // ── helpers ───────────────────────────────────────────────────────
  /// ターミナル設定を元に戻す
  ///
  /// rawモードから通常モードに戻し、
  /// ANSIエスケープシーケンスもリセットする。
  private static func restoreTTY() {
    // tcsetattr: 保存しておいた元の設定を復元
    // これによりエコーや行バッファリングが元に戻る
    tcsetattr(fd, TCSANOW, &oldTerm)
    
    // ANSIリセットシーケンスを出力
    // \u{1B}[0m: すべてのテキスト装飾をリセット
    // （色、太字、下線などをデフォルトに戻す）
    //
    // fputs: 文字列を出力（改行なし）
    // 代替案：
    // - print(): Swift標準だが、改行が追加される
    // - write(STDOUT_FILENO, ...): より低レベルだが、
    //   文字列処理が面倒
    // - FileHandle.standardOutput.write: Foundationだが、
    //   Data変換が必要
    // 選択理由：fputsは改行なしで直接出力、シンプル
    fputs("\u{1B}[0m", stdout)
    
    // バッファをフラッシュして即座に反映
    // 代替案：
    // - setbuf(stdout, NULL): バッファリング無効化
    //   欠点：すべての出力が非効率になる
    // - setvbuf: 行バッファリングに変更
    //   欠点：改行がないと出力されない
    // 選択理由：必要な時だけフラッシュする方が効率的
    fflush(stdout)
  }
  // ESCシーケンスのバッファと処理
  /// ESCシーケンスを一時的に保存するバッファ
  ///
  /// ESCシーケンスとは：
  /// - 複数バイトで1つのキーを表現する仕組み
  /// - 例: 矢印キー↑ = ESC [ A (3バイト)
  /// - ESC単体の場合もあるため、判定が複雑
  private static var escBuffer: [UInt8] = []
  
  /// ESCキー単体を判定するためのタイマー
  ///
  /// ESCキーの判定が難しい理由：
  /// - ESC単体: エスケープキーが押された
  /// - ESC + 他: 矢印キーなどの特殊キー
  /// → 一定時間待って続きが来なければESC単体と判定
  private static var escTimer: DispatchWorkItem?
  
  /// バイトをKeyboardEventに変換
  ///
  /// 単一のバイトを解析して、適切なKeyboardEventに変換します。
  /// ESCシーケンス（複数バイトで1つのキーを表現）も処理します。
  ///
  /// - Parameter byte: 入力されたバイト（0-255）
  /// - Returns: 対応するKeyboardEvent、または処理中の場合nil
  ///
  /// 処理の流れ：
  /// 1. ESCシーケンス処理中かチェック
  /// 2. ESCキー（27）の開始処理
  /// 3. 通常キーの変換
  private static func translate(byte: UInt8) -> KeyboardEvent? {
    // ESCシーケンスの処理
    // ESCバッファに内容がある = ESCシーケンス処理中
    if !escBuffer.isEmpty {
      escBuffer.append(byte)
      
      // 矢印キーのESCシーケンス判定
      // 矢印キーは "ESC [ X" の3バイトパターン：
      // - ESC (27) + [ (91) + A/B/C/D (65/66/67/68)
      // ESC [ が来た時点で矢印キーの可能性を判定
      if escBuffer.count >= 2 && escBuffer[0] == 27 && escBuffer[1] == 91 {
        // 3バイト目を待つ
        if escBuffer.count >= 3 {
          let seq = escBuffer
          escBuffer.removeAll()
          escTimer?.cancel()  // タイマーをキャンセル
          
          // 3バイト目で矢印の方向を判定
          switch seq[2] {
          case 65: return .init(key: .up)     // ESC [ A = ↑
          case 66: return .init(key: .down)   // ESC [ B = ↓
          case 67: return .init(key: .right)  // ESC [ C = →
          case 68: return .init(key: .left)   // ESC [ D = ←
          default: 
            // 矢印キーではないESCシーケンス
            // 他の特殊キー（F1-F12など）の可能性もあるが
            // 現在は未対応なので単独のESCとして扱う
            return .init(key: .escape)
          }
        }
      } else if escBuffer.count >= 2 {
        // ESC [ ではない2バイト目が来た場合
        // これは矢印キーではないので、単独のESCとして扱う
        escBuffer.removeAll()
        escTimer?.cancel()  // タイマーをキャンセル
        return .init(key: .escape)
      }
      
      // まだシーケンスが完成していない（2バイト目まで）
      // 次のバイトを待つためnilを返す
      return nil
    }
    
    // ESCキーの開始
    if byte == 27 {
      escBuffer.append(byte)
      
      // 既存のタイマーをキャンセル
      escTimer?.cancel()
      
      // 50ms後に単独のESCとして処理するタイマーを設定
      // なぜタイマーが必要か：
      // - ESC単体: すぐに判定したい
      // - ESCシーケンス: 続きのバイトを待つ必要がある
      // → 50ms以内に続きが来なければESC単体と判定
      let timer = DispatchWorkItem {
        // タイマー実行時、まだバッファにESCのみなら
        // 単独のESCキーとして処理
        if escBuffer.count == 1 && escBuffer[0] == 27 {
          escBuffer.removeAll()
          if let handler = currentEventHandler {
            handler(.init(key: .escape))
          }
        }
      }
      escTimer = timer
      
      // 50ミリ秒後にタイマーを実行
      // 人間の入力速度を考慮した値
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.05, execute: timer)
      
      return nil
    }
    
    // 通常のキー
    // ASCIIコードからKeyboardEventへの変換
    switch byte {
    case 9:         // TABキー
      return .init(key: .tab)
    case 10, 13:    // 改行（LF）またはキャリッジリターン（CR）
      return .init(key: .enter)
    case 32:        // スペースキー
      return .init(key: .space)
    case 127:       // DELキー（BackspaceとしてMacでは使われる）
      return .init(key: .backspace)
    case 97...122:  // 小文字 a-z
      return .init(key: .character(Character(UnicodeScalar(byte))))
    case 65...90:   // 大文字 A-Z
      return .init(key: .character(Character(UnicodeScalar(byte))))
    case 48...57:   // 数字 0-9
      return .init(key: .character(Character(UnicodeScalar(byte))))
    default:        // その他のキー（現在は未対応）
      return nil
    }
  }
}

// MARK: – C シンボル
/// C言語から呼び出し可能な関数（プログラム終了時）
///
/// @_cdeclはSwiftの関数をC言語から呼び出し可能にする属性。
/// atexit()に登録するため、C言語の関数として公開する必要がある。
///
/// なぜC関数が必要か：
/// - atexit()はC関数ポインタを期待（void (*)(void)型）
/// - SwiftのクロージャはABI（Application Binary Interface）が異なる
/// - @_cdeclで明示的にC ABIに準拠させる必要がある
///
/// Darwin固有の注意点：
/// - macOSではatexit()は最大32個まで登録可能（POSIX準拠）
/// - 登録順と逆順で実行される（LIFO）
@_cdecl("c_restoreTTY") private func c_restoreTTY() { 
  InputLoop.stop() 
}

/// C言語から呼び出し可能な関数（SIGINT受信時）
///
/// SIGINT（Ctrl+C）を受信したときの処理。
/// ターミナル設定を復元してからプログラムを終了する。
///
/// - Parameter s: シグナル番号（SIGINT = 2）
///
/// シグナルハンドラーの制約：
/// - 非同期シグナル安全（async-signal-safe）な関数のみ使用可
/// - Swift関数の多くは非安全（メモリ管理、ディスパッチなど）
/// - 最小限の処理に留める必要がある
///
/// exit()について：
/// - 代替案：_exit(): より低レベル、atexitハンドラーをスキップ
/// - 代替案：abort(): 異常終了扱い、コアダンプ生成
/// - 選択理由：exit()は正常終了扱い、クリーンアップも実行
@_cdecl("c_sigint") private func c_sigint(_ s: Int32) {
  InputLoop.stop()  // ターミナル設定を復元
  exit(s)          // プログラムを終了（通常SIGINTは130で終了）
}
