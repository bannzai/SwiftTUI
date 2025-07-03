import Foundation

enum InputLoop {
  private static var source: DispatchSourceRead?

  /// RenderLoop.mount 内で呼ぶ
  static func start(eventHandler: @escaping (KeyboardEvent) -> Void) {
    let fd = STDIN_FILENO
    // ---- raw mode 設定（簡略：詳細な termios 設定は省略） ----
    var old = termios()
    tcgetattr(fd, &old)
    var raw = old
    cfmakeraw(&raw)
    tcsetattr(fd, TCSANOW, &raw)

    let queue = DispatchQueue(label: "SwiftTUI.Input")
    source = DispatchSource.makeReadSource(fileDescriptor: fd,
                                           queue: queue)
    source?.setEventHandler {
      var buf: [UInt8] = [0]
      let n = read(fd, &buf, 1)
      guard n == 1 else { return }
      if let ev = Self.translate(byte: buf[0]) {
        eventHandler(ev)
      }
    }
    source?.resume()
  }

  /// 超簡易：1 バイトだけを解析
  private static func translate(byte: UInt8) -> KeyboardEvent? {
    switch byte {
    case 10:   return KeyboardEvent(key: .enter)
    case 27:   return KeyboardEvent(key: .escape)
    case 105:  return KeyboardEvent(key: .character("i"))   // 'i'
    default:   return nil
    }
  }
}
