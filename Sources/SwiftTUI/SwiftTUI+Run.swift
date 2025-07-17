/// SwiftTUIアプリケーションのエントリーポイント
///
/// このファイルは、SwiftTUIアプリケーションの起動処理を担当します。
/// SwiftUIの`App.run()`に相当する機能を提供し、ターミナル上でUIを実行します。
///
/// 処理の流れ：
/// 1. `SwiftTUI.run()`メソッドでViewを受け取る
/// 2. ViewをLayoutView（描画可能な形式）に変換
/// 3. CellRenderLoopでターミナルへのレンダリングを開始
/// 4. RunLoop.main.run()でイベント待機状態に入る
///
/// TUI（Terminal User Interface）とは：
/// - ターミナル上で動作するグラフィカルなユーザーインタフェース
/// - 文字、色、枠線を使ってGUIのような見た目を実現
/// - キーボード入力で操作（マウスは通常使用しない）

import Foundation

/// グローバルなキーボードイベントハンドラー
///
/// アプリケーション全体で共通のキーボード処理を定義できます。
/// 例：特定のショートカットキーでメニューを開く、ヘルプを表示するなど
///
/// 使用例：
/// ```swift
/// GlobalKeyHandler.handler = { event in
///     if event.key == .character("?") {
///         showHelp()
///         return true  // イベントを処理した
///     }
///     return false  // イベントを処理しなかった
/// }
/// ```
public struct GlobalKeyHandler {
  /// キーボードイベントを処理するクロージャ
  /// - Returns: イベントを処理した場合はtrue、処理しなかった場合はfalse
  public static var handler: ((KeyboardEvent) -> Bool)?
}

/// LayoutViewをLegacyViewでラップし、各種プロトコルを実装する構造体
///
/// この構造体は、SwiftUIライクなView APIと、内部のレンダリングシステムをつなぐ
/// アダプターの役割を果たします。
///
/// 実装しているプロトコル：
/// - LegacyView: 旧来のレンダリングシステムとの互換性
/// - LayoutView: Yogaレイアウトエンジンとの統合
/// - CellLayoutView: セルベースレンダリングシステムとの統合
private struct LayoutViewWrapper: LegacyView, LayoutView, CellLayoutView {
  /// ラップする実際のLayoutView
  let layoutView: any LayoutView

  /// Yogaレイアウトエンジン用のノードを作成
  ///
  /// Yogaは、Facebook製のFlexboxレイアウトエンジンです。
  /// このメソッドは、ViewのレイアウトプロパティをYogaが理解できる形式に変換します。
  ///
  /// - Returns: レイアウト計算用のYogaNode
  func makeNode() -> YogaNode {
    layoutView.makeNode()
  }

  /// 旧来のレンダリングシステム用の描画メソッド（文字列バッファ版）
  ///
  /// - Parameters:
  ///   - origin: 描画開始位置（x, y座標）
  ///   - buffer: 文字列の2次元配列（画面全体を表現）
  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    layoutView.paint(origin: origin, into: &buffer)
  }

  /// LegacyViewプロトコル用のレンダリングメソッド
  ///
  /// - Parameter buffer: 描画先の文字列バッファ
  func render(into buffer: inout [String]) {
    layoutView.render(into: &buffer)
  }

  /// セルベースレンダリングシステム用の描画メソッド
  ///
  /// セルベースレンダリングとは：
  /// - ターミナルの各文字位置（セル）を個別に管理
  /// - 各セルに文字、文字色、背景色、スタイル（太字等）を設定可能
  /// - より精密な描画制御が可能（差分更新による高速化も実現）
  ///
  /// - Parameters:
  ///   - origin: 描画開始位置（x, y座標）
  ///   - buffer: セルの2次元配列（CellBuffer）
  func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
    if let cellLayoutView = layoutView as? CellLayoutView {
      // 新しいCellLayoutViewプロトコルを実装している場合
      cellLayoutView.paintCells(origin: origin, into: &buffer)
    } else {
      // 旧来のLayoutViewの場合は、アダプターパターンで変換
      let adapter = CellLayoutAdapter(layoutView)
      adapter.paintCells(origin: origin, into: &buffer)
    }
  }

  /// キーボードイベントを処理
  ///
  /// このメソッドは、ユーザーがキーを押したときに呼ばれます。
  /// イベント処理の優先順位：
  /// 1. グローバルハンドラー（アプリ全体の共通処理）
  /// 2. FocusManager（フォーカスされたViewへの配信）
  /// 3. デフォルト処理（ESCキーで終了）
  ///
  /// - Parameter event: キーボードイベント（押されたキーの情報）
  /// - Returns: イベントを処理した場合はtrue、処理しなかった場合はfalse
  func handle(event: KeyboardEvent) -> Bool {
    // ステップ1: グローバルハンドラーを最初にチェック
    // アプリケーション全体で共通のキー処理（例：ヘルプ表示）があれば実行
    if let globalHandler = GlobalKeyHandler.handler, globalHandler(event) {
      // 画面の再描画をスケジューリング（UIに変更があった可能性があるため）
      CellRenderLoop.scheduleRedraw()
      return true
    }

    // ステップ2: FocusManagerに処理を委譲
    // フォーカスされているView（例：TextField、Button）にイベントを配信
    if FocusManager.shared.handleKeyEvent(event) {
      // フォーカスが移動したり、Viewの状態が変わった場合は再描画
      CellRenderLoop.scheduleRedraw()
      return true
    }

    // ステップ3: デフォルトのキー処理
    // ESCキーが押されたらアプリケーションを終了
    if event.key == .escape {
      CellRenderLoop.shutdown()  // レンダリングループを停止
      return true
    }

    // どこでも処理されなかったイベント
    return false
  }
}

extension SwiftTUI {
  /// SwiftUIライクなAPIでアプリケーションを起動（クロージャ版）
  ///
  /// このメソッドは、SwiftTUIアプリケーションのメインエントリーポイントです。
  /// SwiftUIの`WindowGroup { ContentView() }`に相当します。
  ///
  /// 使用例：
  /// ```swift
  /// SwiftTUI.run {
  ///     ContentView()  // あなたのルートView
  /// }
  /// ```
  ///
  /// 処理の流れ：
  /// 1. クロージャからViewインスタンスを作成
  /// 2. ViewをLayoutView（描画可能な形式）に変換
  /// 3. CellRenderLoopでターミナルレンダリングを開始
  /// 4. RunLoopでイベント待機（キー入力など）
  ///
  /// - Parameter view: ルートViewを返すクロージャ
  public static func run<Content: View>(_ view: @escaping () -> Content) {
    // ステップ1: Viewインスタンスを一度だけ作成
    // （再レンダリング時も同じインスタンスを使用）
    let viewInstance = view()

    // ステップ2: セルベースのRenderLoopを使用してマウント
    CellRenderLoop.mount {
      // ViewRenderer: SwiftUIライクなViewを内部のLayoutViewに変換
      let layoutView = ViewRenderer.renderView(viewInstance)
      // LayoutViewWrapper: 各種プロトコルを実装したアダプター
      return LayoutViewWrapper(layoutView: layoutView)
    }

    // ステップ3: メインループを開始
    // RunLoop.main.run()により、プログラムは終了せずイベント待機状態になる
    // これがないと、プログラムは即座に終了してしまう
    RunLoop.main.run()
  }

  /// View型を直接受け取るバージョン（インスタンス版）
  ///
  /// 既にインスタンス化されたViewを受け取るバージョンです。
  /// 主に後方互換性のために提供されています。
  ///
  /// 使用例：
  /// ```swift
  /// let contentView = ContentView()
  /// SwiftTUI.run(contentView)
  /// ```
  ///
  /// 通常は上記のクロージャ版を使用することを推奨します。
  ///
  /// - Parameter view: ルートViewのインスタンス
  public static func run<Content: View>(_ view: Content) {
    // 既にインスタンス化されたViewをそのまま使用
    CellRenderLoop.mount {
      let layoutView = ViewRenderer.renderView(view)
      return LayoutViewWrapper(layoutView: layoutView)
    }

    // メインループを開始（詳細は上記のクロージャ版を参照）
    RunLoop.main.run()
  }
}
