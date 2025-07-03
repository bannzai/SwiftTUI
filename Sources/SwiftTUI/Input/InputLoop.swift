import Foundation
import Darwin          // termios / STDIN_FILENO

/// 標準入力を RawMode で読み取り、1 バイトごとに KeyboardEvent を生成
enum InputLoop {
  private static var source: DispatchSourceRead?
  private static var originalTermios = termios()

  /// RenderLoop.mount 内から 1 回だけ呼ばれる
  static func start(eventHandler: @escaping (KeyboardEvent) -> Void) {
    let fd = STDIN_FILENO

    // --- ① Raw Mode に切り替え ----------------------------------------
    tcgetattr(fd, &originalTermios)              // 現在の設定を保存
    var raw = originalTermios
    cfmakeraw(&raw)                              // 非 canonical・エコーなし
    tcsetattr(fd, TCSANOW, &raw)

    // --- ② DispatchSourceRead で非同期監視 -----------------------------
    let queue = DispatchQueue(label: "SwiftTUI.Input")
    source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: queue)

    source?.setEventHandler {
      while true {
        var byte: UInt8 = 0
        let n = read(fd, &byte, 1)
        guard n == 1 else { break }

        if let ev = Self.translate(byte: byte) {
          eventHandler(ev)                 // ← RenderLoop へ
        }
      }
    }

    source?.setCancelHandler {
      // アプリ終了時に TTY 設定を元に戻す
      tcsetattr(fd, TCSANOW, &originalTermios)
    }

    source?.resume()
  }

  // --- ③ 単バイト → KeyboardEvent ----------------------------------------
  private static func translate(byte: UInt8) -> KeyboardEvent? {
    switch byte {
    case 27:                // ESC
      return KeyboardEvent(key: .escape)

    case 97...122:          // 'a' – 'z'
      let c = Character(UnicodeScalar(byte))
      return KeyboardEvent(key: .character(c))

    default:
      return nil          // それ以外は無視（必要に応じて拡張）
    }
  }
}
