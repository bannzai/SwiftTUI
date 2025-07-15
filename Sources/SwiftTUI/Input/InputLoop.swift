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

enum InputLoop {

  // ── internal state ────────────────────────────────────────────────
  /// 非同期読み取りソース
  ///
  /// DispatchSourceReadは、ファイルディスクリプタから
  /// データが読み取り可能になったときに通知するオブジェクト。
  /// キーボード入力を非同期で監視するために使用。
  private static var src : DispatchSourceRead?
  
  /// 元のターミナル設定のバックアップ
  ///
  /// termios構造体には、ターミナルの詳細な設定が含まれる：
  /// - 入力モード（エコー、改行処理など）
  /// - 出力モード
  /// - 制御文字の設定
  /// プログラム終了時に元の設定に戻すため保存。
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
  private static var currentEventHandler: ((KeyboardEvent)->Void)?

  // ── public ────────────────────────────────────────────────────────
  /// キーボード入力監視を開始
  ///
  /// アプリケーション起動時にRenderLoopから呼ばれる。
  /// ターミナルをrawモードに設定し、キーボード入力の
  /// 非同期監視を開始する。
  ///
  /// - Parameter eventHandler: キーイベント発生時のコールバック
  static func start(eventHandler: @escaping (KeyboardEvent)->Void) {
    currentEventHandler = eventHandler

    // ① raw-mode へ切り替え
    // tcgetattr: 現在のターミナル設定を取得
    // &oldTerm: 設定を保存する構造体へのポインタ
    tcgetattr(fd, &oldTerm)
    
    // cfmakeraw: termios構造体をrawモード用に設定
    // rawモードの特徴：
    // - 1文字ずつ即座に読み取り（バッファリングなし）
    // - エコーなし（入力文字が画面に表示されない）
    // - 特殊文字処理なし（Ctrl+Cなども通常文字として受信）
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
    atexit(c_restoreTTY)
    
    // signal: シグナルハンドラーを登録
    // SIGINT: Ctrl+Cが押されたときのシグナル
    // c_sigint: シグナル受信時の処理関数
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
      // 戻り値: 読み取ったバイト数（エラー時は-1）
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
    fputs("\u{1B}[0m", stdout)
    
    // バッファをフラッシュして即座に反映
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
  private static func translate(byte: UInt8)->KeyboardEvent? {
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
@_cdecl("c_restoreTTY") private func c_restoreTTY() { 
  InputLoop.stop() 
}

/// C言語から呼び出し可能な関数（SIGINT受信時）
///
/// SIGINT（Ctrl+C）を受信したときの処理。
/// ターミナル設定を復元してからプログラムを終了する。
///
/// - Parameter s: シグナル番号（SIGINT = 2）
@_cdecl("c_sigint") private func c_sigint(_ s:Int32){
  InputLoop.stop()  // ターミナル設定を復元
  exit(s)          // プログラムを終了
}
