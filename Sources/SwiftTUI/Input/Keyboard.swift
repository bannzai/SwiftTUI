/// KeyboardKey：キーボードの各キーを表現する列挙型
///
/// TUIアプリケーションで扱うキーボード入力を抽象化します。
/// 通常の文字キーと特殊キーの両方を統一的に扱えるようにします。
///
/// TUI初心者向け解説：
/// - GUIと違いTUIはキーボードが主な入力手段
/// - マウスは使えない（または限定的）ため、すべての操作をキーで行う
/// - 特殊キー（Tab、矢印キーなど）の扱いが重要
///
/// なぜ列挙型を使うのか：
/// - キーの種類は有限で決まっている
/// - パターンマッチングで確実に処理できる
/// - 型安全性が保証される
public enum KeyboardKey: Equatable {
  /// 通常の文字キー（a-z、A-Z、0-9、記号など）
  ///
  /// 例：
  /// - .character("a") - 小文字のa
  /// - .character("A") - 大文字のA（Shiftキー押下時）
  /// - .character("1") - 数字の1
  /// - .character("!") - 感嘆符（Shift+1）
  case character(Character)    // a–z
  
  /// characterの別名（後方互換性のため）
  ///
  /// 旧バージョンとの互換性を保つための別名。
  /// 新しいコードではcharacterを使用することを推奨。
  case char(Character)         // alias for backward compatibility
  
  /// ESCキー
  ///
  /// 用途：
  /// - モーダルダイアログを閉じる
  /// - 操作をキャンセル
  /// - Vimモードの切り替え
  /// ASCII: 27
  case escape
  
  /// Enterキー（改行）
  ///
  /// 用途：
  /// - テキスト入力の確定
  /// - ボタンの押下
  /// - 選択の決定
  /// ASCII: 10 (LF) または 13 (CR)
  case enter
  
  /// スペースキー
  ///
  /// 用途：
  /// - スペース文字の入力
  /// - チェックボックスのトグル
  /// - ボタンの押下（Enterの代替）
  /// ASCII: 32
  case space
  
  /// Tabキー
  ///
  /// 用途：
  /// - フォーカスの移動（次の要素へ）
  /// - インデントの入力
  /// - オートコンプリート
  /// ASCII: 9
  case tab
  
  /// Backspaceキー
  ///
  /// 用途：
  /// - カーソル位置の前の文字を削除
  /// - 前のページに戻る（ブラウザライク）
  /// ASCII: 127（macOSでは）
  case backspace
  
  /// Deleteキー
  ///
  /// 用途：
  /// - カーソル位置の次の文字を削除
  /// - 選択項目の削除
  /// 注：Backspaceとは削除方向が逆
  case delete
  
  /// 上矢印キー
  ///
  /// 用途：
  /// - カーソルを上に移動
  /// - リスト内で前の項目を選択
  /// - 履歴の前の項目を表示
  /// ESCシーケンス: ESC [ A
  case up
  
  /// 下矢印キー
  ///
  /// 用途：
  /// - カーソルを下に移動
  /// - リスト内で次の項目を選択
  /// - 履歴の次の項目を表示
  /// ESCシーケンス: ESC [ B
  case down
  
  /// 左矢印キー
  ///
  /// 用途：
  /// - カーソルを左に移動
  /// - テキスト内で前の文字へ
  /// - 前のタブへ切り替え
  /// ESCシーケンス: ESC [ D
  case left
  
  /// 右矢印キー
  ///
  /// 用途：
  /// - カーソルを右に移動
  /// - テキスト内で次の文字へ
  /// - 次のタブへ切り替え
  /// ESCシーケンス: ESC [ C
  case right
  
  /// Homeキー
  ///
  /// 用途：
  /// - 行の先頭へ移動
  /// - リストの最初へ移動
  /// - ページの最上部へ
  case home
  
  /// Endキー
  ///
  /// 用途：
  /// - 行の末尾へ移動
  /// - リストの最後へ移動
  /// - ページの最下部へ
  case end
}

/// KeyboardEvent：キーボードイベントを表す構造体
///
/// キーが押されたときに生成されるイベント。
/// 将来的には修飾キー（Ctrl、Alt、Cmd）の情報も
/// 含められるよう拡張可能な設計。
///
/// 使用例：
/// ```swift
/// func handle(event: KeyboardEvent) -> Bool {
///     switch event.key {
///     case .character("q"):
///         // qキーが押された
///         quit()
///     case .tab:
///         // Tabキーが押された
///         focusNext()
///     default:
///         break
///     }
/// }
/// ```
public struct KeyboardEvent {
  /// 押されたキー
  ///
  /// KeyboardKey型で、どのキーが押されたかを表現。
  /// 文字キーと特殊キーの両方を統一的に扱える。
  public let key: KeyboardKey
  
  // 将来的な拡張のための予約
  // public let modifiers: KeyModifiers?  // Ctrl、Alt、Cmdなど
  // public let timestamp: TimeInterval?  // イベント発生時刻
}
