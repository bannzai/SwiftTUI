import Foundation
import Darwin        // termios, signal

enum InputLoop {

  // ── internal state ────────────────────────────────────────────────
  private static var src : DispatchSourceRead?
  private static var oldTerm = termios()
  private static let fd = STDIN_FILENO
  private static var currentEventHandler: ((KeyboardEvent)->Void)?

  // ── public ────────────────────────────────────────────────────────
  static func start(eventHandler: @escaping (KeyboardEvent)->Void) {
    currentEventHandler = eventHandler

    // ① raw-mode へ
    tcgetattr(fd, &oldTerm)
    var raw = oldTerm; cfmakeraw(&raw)
    tcsetattr(fd, TCSANOW, &raw)

    // ② 終了シグナルをフック
    atexit(c_restoreTTY)
    signal(SIGINT, c_sigint)

    // ③ 非同期 read
    let q = DispatchQueue(label: "SwiftTUI.Input")
    src = DispatchSource.makeReadSource(fileDescriptor: fd, queue: q)
    src?.setEventHandler {
      var byte: UInt8 = 0
      while read(fd, &byte, 1) == 1 {
        fputs("[InputLoop] Read byte: \(byte)\n", stderr)
        if let ev = Self.translate(byte: byte) { 
          fputs("[InputLoop] Translated to event: \(ev.key)\n", stderr)
          eventHandler(ev) 
        }
      }
    }
    src?.resume()
  }

  /// RenderLoop.shutdown から呼ぶ
  static func stop() {
    src?.cancel()
    restoreTTY()
  }

  // ── helpers ───────────────────────────────────────────────────────
  private static func restoreTTY() {
    tcsetattr(fd, TCSANOW, &oldTerm)
    fputs("\u{1B}[0m", stdout)      // ANSI リセット
    fflush(stdout)
  }
  // ESCシーケンスのバッファ
  private static var escBuffer: [UInt8] = []
  private static var escTimer: DispatchWorkItem?
  
  private static func translate(byte: UInt8)->KeyboardEvent? {
    // ESCシーケンスの処理
    if !escBuffer.isEmpty {
      escBuffer.append(byte)
      
      // 矢印キーのESCシーケンス判定
      // ESC [ が来た時点で矢印キーの可能性を判定
      if escBuffer.count >= 2 && escBuffer[0] == 27 && escBuffer[1] == 91 {
        // 3バイト目を待つ
        if escBuffer.count >= 3 {
          let seq = escBuffer
          escBuffer.removeAll()
          escTimer?.cancel()  // タイマーをキャンセル
          
          switch seq[2] {
          case 65: return .init(key: .up)     // ESC [ A
          case 66: return .init(key: .down)   // ESC [ B
          case 67: return .init(key: .right)  // ESC [ C
          case 68: return .init(key: .left)   // ESC [ D
          default: 
            // 矢印キーではないESCシーケンス - 単独のESCとして扱う
            return .init(key: .escape)
          }
        }
      } else if escBuffer.count >= 2 {
        // ESC [ ではない2バイト目が来た場合、単独のESCとして扱う
        escBuffer.removeAll()
        escTimer?.cancel()  // タイマーをキャンセル
        return .init(key: .escape)
      }
      
      // まだシーケンスが完成していない（2バイト目まで）
      return nil
    }
    
    // ESCキーの開始
    if byte == 27 {
      escBuffer.append(byte)
      
      // 既存のタイマーをキャンセル
      escTimer?.cancel()
      
      // 50ms後に単独のESCとして処理するタイマーを設定
      let timer = DispatchWorkItem {
        if escBuffer.count == 1 && escBuffer[0] == 27 {
          escBuffer.removeAll()
          if let handler = currentEventHandler {
            handler(.init(key: .escape))
          }
        }
      }
      escTimer = timer
      DispatchQueue.global().asyncAfter(deadline: .now() + 0.05, execute: timer)
      
      return nil
    }
    
    // 通常のキー
    switch byte {
    case 9:         return .init(key: .tab)
    case 10, 13:    return .init(key: .enter)
    case 32:        return .init(key: .space)
    case 127:       return .init(key: .backspace)
    case 97...122:  return .init(key: .character(Character(UnicodeScalar(byte))))
    case 65...90:   return .init(key: .character(Character(UnicodeScalar(byte))))
    case 48...57:   return .init(key: .character(Character(UnicodeScalar(byte))))
    default:        return nil
    }
  }
}

// MARK: – C シンボル
@_cdecl("c_restoreTTY") private func c_restoreTTY() { InputLoop.stop() }
@_cdecl("c_sigint")     private func c_sigint(_ s:Int32){
  InputLoop.stop(); exit(s)
}
