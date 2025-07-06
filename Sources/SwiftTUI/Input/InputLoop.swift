import Foundation
import Darwin        // termios, signal

enum InputLoop {

  // ── internal state ────────────────────────────────────────────────
  private static var src : DispatchSourceRead?
  private static var oldTerm = termios()
  private static let fd = STDIN_FILENO

  // ── public ────────────────────────────────────────────────────────
  static func start(eventHandler: @escaping (KeyboardEvent)->Void) {

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
        if let ev = Self.translate(byte: byte) { 
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
  
  private static func translate(byte: UInt8)->KeyboardEvent? {
    // ESCシーケンスの処理
    if !escBuffer.isEmpty {
      escBuffer.append(byte)
      
      // 矢印キーのESCシーケンス判定
      if escBuffer.count >= 3 {
        let seq = escBuffer
        escBuffer.removeAll()
        
        // 矢印キーのESCシーケンス
        if seq.count >= 3 && seq[0] == 27 && seq[1] == 91 {  // ESC [
          switch seq[2] {
          case 65: return .init(key: .up)     // ESC [ A
          case 66: return .init(key: .down)   // ESC [ B
          case 67: return .init(key: .right)  // ESC [ C
          case 68: return .init(key: .left)   // ESC [ D
          default: break
          }
        }
        
        // 単独のESC（簡易実装 - 3バイト待ってもESC[X形式でなければESC）
        if seq.count == 1 && seq[0] == 27 {
          return .init(key: .escape)
        }
      }
      
      // まだシーケンスが完成していない（2バイト目まで）
      return nil
    }
    
    // ESCキーの開始
    if byte == 27 {
      escBuffer.append(byte)
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
