import Foundation
import Darwin               // termios / STDIN_FILENO

enum InputLoop {

  // MARK: - Private state
  private static var source: DispatchSourceRead?
  private static var originalTermios = termios()
  private static let DEBUG = true

  // MARK: - Public
  /// RenderLoop.mount 内から 1 回だけ呼ぶ
  static func start(eventHandler: @escaping (KeyboardEvent) -> Void) {

    let fd = STDIN_FILENO

    // ① Raw mode へ
    tcgetattr(fd, &originalTermios)
    var raw = originalTermios
    cfmakeraw(&raw)
    tcsetattr(fd, TCSANOW, &raw)
    if DEBUG {
      print("[DEBUG] TTY switched to raw mode")
    }

    // ② 非同期読み取り
    let queue = DispatchQueue(label: "SwiftTUI.Input")
    source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: queue)

    source?.setEventHandler {
      while true {
        var byte: UInt8 = 0
        let n = read(fd, &byte, 1)
        if n != 1 { break }

        if DEBUG {
          print("[DEBUG] read byte:", byte)
        }

        if let ev = Self.translate(byte: byte) {
          if DEBUG {
            print("[DEBUG] translated event:", ev)
          }
          eventHandler(ev)
        }
      }
    }

    source?.setCancelHandler {
      tcsetattr(fd, TCSANOW, &originalTermios)
      if DEBUG {
        print("[DEBUG] TTY restored original mode")
      }
    }

    source?.resume()
  }

  // ③ 1 バイト → KeyboardEvent
  private static func translate(byte: UInt8) -> KeyboardEvent? {
    switch byte {
    case 27:
      return KeyboardEvent(key: .escape)
    case 97 ... 122:                    // a–z
      let c = Character(UnicodeScalar(byte))
      return KeyboardEvent(key: .character(c))
    default:
      return nil
    }
  }
}
