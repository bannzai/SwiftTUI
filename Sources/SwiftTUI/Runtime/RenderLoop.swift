//  Sources/SwiftTUI/Runtime/RenderLoop.swift
import Foundation

public enum RenderLoop {
  public static func mount<V: View>(_ build: @escaping () -> V) {
    makeRoot = { AnyView(build()) }
    fullRedraw()                         // 初期フレーム
  }

  // MARK: - Internal -------------------------------------------------------

  /// 次フレームを生成するクロージャ
  private static var makeRoot: (() -> AnyView)?

  /// “すでに予約済みか” フラグ（描画バッチ向け）
  private static var redrawPending = false

  /// 描画専用シリアルキュー —— `readLine()` でメインが塞がっても動ける
  private static let renderQueue = DispatchQueue(label: "SwiftTUI.RenderLoop")

  /// 前回フレームの行バッファ
  private static var prevBuffer: [String] = []

  /// State などから呼ばれる再描画予約
  static func scheduleRedraw() {
    guard !redrawPending else { return }
    redrawPending = true
    renderQueue.async {
      incrementalRedraw()
      redrawPending = false
    }
  }

  // MARK: - 描画ルーチン ----------------------------------------------------

  /// フルクリアして全行描画（初回／エッジケース用）
  private static func fullRedraw() {
    guard let makeRoot else { return }

    // 全消去（2J）＋カーソルホーム（H）
    print("\u{1B}[2J\u{1B}[H", terminator: "")

    var buffer: [String] = []
    makeRoot().render(into: &buffer)
    buffer.forEach { print($0) }
    prevBuffer = buffer

    fflush(stdout)
  }

  /// 行単位の差分適用 — 変わった行だけを書き換える
  private static func incrementalRedraw() {
    guard let makeRoot else { return }

    var next: [String] = []
    makeRoot().render(into: &next)

    // ① 共通行を比較し、差分行のみ更新
    let common = min(prevBuffer.count, next.count)
    for row in 0..<common where prevBuffer[row] != next[row] {
      moveCursor(to: row)
      clearLine()
      print(next[row], terminator: "")
    }

    // ② 行が増えた場合 → 追加分を描画
    if next.count > prevBuffer.count {
      for row in prevBuffer.count..<next.count {
        moveCursor(to: row)
        clearLine()
        print(next[row], terminator: "")
      }
    }

    // ③ 行が減った場合 → 余剰行をクリア
    if next.count < prevBuffer.count {
      for row in next.count..<prevBuffer.count {
        moveCursor(to: row)
        clearLine()
      }
    }

    // ④ カーソルを末尾＋1 行目へ
    moveCursor(to: next.count)

    prevBuffer = next
    fflush(stdout)
  }

  // MARK: - ANSI ヘルパ -----------------------------------------------------

  /// 0-origin 行番号を 1-origin に変換して移動
  private static func moveCursor(to row: Int) {
    print("\u{1B}[\(row + 1);1H", terminator: "")
  }

  /// 現在行を全消去
  private static func clearLine() {
    print("\u{1B}[2K", terminator: "")
  }
}
