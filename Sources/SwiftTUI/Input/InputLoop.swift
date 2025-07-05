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
        if let ev = Self.translate(byte: byte) { eventHandler(ev) }
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
  private static func translate(byte: UInt8)->KeyboardEvent? {
    switch byte {
    case 27:        return .init(key: .escape)
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
