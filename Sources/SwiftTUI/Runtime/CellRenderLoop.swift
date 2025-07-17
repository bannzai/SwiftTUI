/// CellRenderLoop：SwiftTUIのレンダリングエンジンの中心
///
/// このファイルは、SwiftTUIの心臓部であるレンダリングループを実装しています。
/// 主な責務：
/// 1. View階層をLayoutViewに変換
/// 2. Yogaでレイアウト計算
/// 3. CellBufferに描画
/// 4. 差分をターミナルに出力
/// 5. 再レンダリングの管理
///
/// セルベースレンダリングとは：
/// - ターミナルの各文字位置（セル）を個別に管理
/// - 前回と今回の差分だけを更新（高速化）
/// - 各セルに文字、色、スタイルを設定可能

import Darwin  // ターミナル制御用のシステムコール
import Foundation
import yoga  // Flexboxレイアウトエンジン

// Darwin: macOS/iOS向けのシステムフレームワーク
// ioctl、winsize構造体、STDOUT_FILENO定数などを提供
// Linux版では<sys/ioctl.h>、<unistd.h>をインポート

/// セルベースレンダリングをサポートする新しいRenderLoop
///
/// enumを使う理由：
/// - インスタンス化できない（すべてstaticメンバー）
/// - 名前空間として機能
/// - シングルトンパターンの一種
public enum CellRenderLoop {
  /// デバッグモードフラグ（trueにすると詳細ログを出力）
  public static var DEBUG = false

  /// ルートViewを生成するクロージャ
  /// SwiftTUI.run()から設定される
  private static var makeRoot: (() -> LegacyAnyView)?

  /// 現在のルートViewのキャッシュ
  /// 再レンダリング時に使用
  private static var cachedRoot: LegacyAnyView?

  /// LayoutViewのキャッシュ（パフォーマンス最適化）
  private static var cachedLayoutView: (any LayoutView)?

  /// レンダリング専用のディスパッチキュー
  /// 非同期でレンダリングを実行し、メインスレッドをブロックしない
  private static let rq = DispatchQueue(label: "SwiftTUI.CellRender")

  /// 前回のCellBuffer（差分検出用）
  /// これと現在のバッファを比較して、変更箇所だけを更新
  private static var prevCellBuffer: CellBuffer?

  /// 再描画が予約されているかのフラグ
  /// 連続した再描画要求を1回にまとめる（バッチ処理）
  private static var redrawPending = false

  /// アプリケーションのルートViewをマウント（初期化）
  ///
  /// SwiftTUI.run()から呼ばれる最初のメソッドです。
  /// アプリケーション起動時に一度だけ実行されます。
  ///
  /// - Parameter build: ルートViewを生成するクロージャ
  ///
  /// 処理の流れ：
  /// 1. ルートView生成クロージャを保存
  /// 2. 初回のViewインスタンスを作成
  /// 3. LayoutViewとしてキャッシュ
  /// 4. 全画面を初回描画
  /// 5. キーボード入力処理を開始
  public static func mount<V: LegacyView>(_ build: @escaping () -> V) {
    // LegacyAnyViewでラップして型を統一
    makeRoot = { LegacyAnyView(build()) }
    cachedRoot = makeRoot?()

    // LayoutViewをキャッシュ（パフォーマンス最適化）
    if let root = cachedRoot as? LayoutView {
      cachedLayoutView = root
    }

    fullRedraw()  // 初回の全画面描画
    startInput()  // キーボード入力監視を開始
  }

  /// 再描画をスケジュール（予約）
  ///
  /// このメソッドは、@Stateの変更やユーザー操作により呼ばれます。
  /// 連続して呼ばれても、実際の再描画は1回にまとめられます（バッチ処理）。
  ///
  /// バッチ処理の利点：
  /// - 複数の状態変更を1回の描画にまとめる
  /// - パフォーマンスの向上
  /// - ちらつきの防止
  public static func scheduleRedraw() {
    // すでに再描画が予約されている場合は何もしない
    guard !redrawPending else { return }

    redrawPending = true

    // レンダリング専用キューで非同期実行
    rq.async {
      incrementalRedraw()  // 差分更新による再描画
      redrawPending = false
    }
  }

  // --- フレーム構築 --------------------------------------------------

  /// 新しいフレーム（CellBuffer）を構築
  ///
  /// このメソッドがレンダリングの中核です。
  /// View階層からCellBufferを生成し、画面に表示する準備をします。
  ///
  /// 処理の流れ：
  /// 1. FocusManagerとButtonLayoutManagerの準備
  /// 2. 最新のView階層を生成
  /// 3. Yogaでレイアウト計算
  /// 4. CellBufferに描画
  /// 5. 完成したバッファを返す
  private static func buildFrame() -> CellBuffer {
    // ステップ1: レンダリング前の準備
    // フォーカスとボタンの状態をリセット
    FocusManager.shared.prepareForRerender()
    ButtonLayoutManager.shared.prepareForRerender()

    // ステップ2: 新しいrootを作成して最新の状態を反映
    guard let makeRoot = makeRoot else {
      // エラーケース：デフォルトサイズの空バッファを返す
      return CellBuffer(width: 80, height: 24)
    }
    let root = makeRoot()
    cachedRoot = root

    // ステップ3: 新しいLayoutViewを作成
    let lv: any LayoutView
    if let layoutView = root as? LayoutView {
      lv = layoutView
      cachedLayoutView = lv
    } else {
      // 従来のレンダリング
      var b: [String] = []
      root.render(into: &b)

      // String配列をCellBufferに変換
      var cellBuffer = CellBuffer(width: 80, height: b.count)
      for (row, line) in b.enumerated() {
        bufferWriteCell(row: row, col: 0, text: line, into: &cellBuffer)
      }
      return cellBuffer
    }

    // 端末幅取得
    // winsize構造体：ターミナルのサイズ情報を保持
    // struct winsize {
    //     unsigned short ws_row;     // 行数（文字単位）
    //     unsigned short ws_col;     // 列数（文字単位）
    //     unsigned short ws_xpixel;  // 横幅（ピクセル単位、通常0）
    //     unsigned short ws_ypixel;  // 高さ（ピクセル単位、通常0）
    // }
    var ws = winsize()

    // ioctl: I/O制御のシステムコール
    // STDOUT_FILENO: 標準出力のファイルディスクリプタ（1）
    // TIOCGWINSZ: "Terminal I/O Control Get WINdow SiZe"の略
    //            ターミナルのウィンドウサイズを取得するリクエスト
    // &ws: 結果を格納するwinsize構造体へのポインタ
    //
    // 代替案：
    // 1. getenv("COLUMNS") / getenv("LINES"): 環境変数から取得
    //    欠点：リアルタイムの変更が反映されない、設定されていない場合がある
    // 2. tput cols / tput lines: 外部コマンド実行
    //    欠点：プロセス起動のオーバーヘッド、移植性の問題
    // 3. ANSI escape sequence (CSI 18 t): ターミナルに問い合わせ
    //    欠点：非同期応答、すべてのターミナルでサポートされない
    // 4. tcgetwinsize() (POSIX.1-2024): 新しいPOSIX標準関数
    //    欠点：まだ広くサポートされていない
    // 選択理由：ioctlは最も確実で高速、POSIXで広くサポートされている
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws)

    // デフォルト値（80×24）は伝統的なVT100ターミナルのサイズ
    let width = Float(ws.ws_col > 0 ? ws.ws_col : 80)
    let height = Int(ws.ws_row > 0 ? ws.ws_row : 24)

    // Yogaレイアウト計算
    let node = lv.makeNode()
    node.calculate(width: width)

    // CellBufferを作成
    var cellBuffer = CellBuffer(width: Int(width), height: height)

    // セルベースレンダリング
    if let cellLayoutView = lv as? CellLayoutView {
      cellLayoutView.paintCells(origin: (0, 0), into: &cellBuffer)
    } else {
      // 従来のLayoutViewをアダプター経由で描画
      let adapter = CellLayoutAdapter(lv)
      adapter.paintCells(origin: (0, 0), into: &cellBuffer)
    }

    if DEBUG {
      dump(cellBuffer)
    }

    // レンダリング完了をFocusManagerに通知
    FocusManager.shared.finishRerendering()

    return cellBuffer
  }

  // --- draw routines --------------------------------------------------
  /// 全画面を完全に再描画
  ///
  /// アプリケーション起動時や、画面全体をクリアする必要がある場合に使用。
  /// 差分更新ではなく、画面全体を書き直します。
  private static func fullRedraw() {
    // ANSIエスケープシーケンスで画面をクリア
    // \u{1B}[2J: 画面全体をクリア
    // \u{1B}[H: カーソルをホームポジション（左上）に移動
    print("\u{1B}[2J\u{1B}[H", terminator: "")

    // 新しいフレームを構築
    let cellBuffer = buildFrame()

    // CellBufferをANSIエスケープシーケンスを含む文字列に変換
    let lines = cellBuffer.toANSILines()

    // 各行をターミナルに出力
    for line in lines {
      print(line)
    }

    // 出力バッファを強制的にフラッシュ（即座に画面に反映）
    // fflush: 出力ストリームのバッファを強制的に書き出す
    // stdout: 標準出力ストリーム（FILE*型）
    //
    // なぜ必要か：
    // - printfやprintは内部バッファに溜めて効率化している
    // - TUIでは即座に画面更新が必要
    // - 行バッファリング（改行で自動フラッシュ）では不十分
    //
    // 代替案：
    // 1. setbuf(stdout, NULL): バッファリング完全無効化
    //    欠点：すべての出力が非効率になる
    // 2. setvbuf(stdout, NULL, _IONBF, 0): 同上
    // 3. write(STDOUT_FILENO, ...): 低レベルI/O（バッファなし）
    //    欠点：文字列処理が面倒、エラー処理が複雑
    // 4. fsync(STDOUT_FILENO): ディスクまで同期
    //    欠点：ターミナル出力には過剰、パフォーマンス低下
    // 選択理由：必要な時だけフラッシュする方が効率的で制御しやすい
    fflush(stdout)

    // 現在のバッファを保存（次回の差分検出用）
    prevCellBuffer = cellBuffer
  }

  /// 差分更新による効率的な再描画
  ///
  /// 前回のバッファと比較し、変更があった行だけを更新します。
  /// これにより、画面のちらつきを防ぎ、パフォーマンスを向上させます。
  ///
  /// 差分更新のアルゴリズム：
  /// 1. 前回と今回のバッファを比較
  /// 2. 異なる行だけを更新
  /// 3. 行数が変わった場合は追加/削除
  private static func incrementalRedraw() {
    // 新しいフレームを構築
    let nextBuffer = buildFrame()
    let nextLines = nextBuffer.toANSILines()

    if let prevBuffer = prevCellBuffer {
      let prevLines = prevBuffer.toANSILines()
      let common = min(prevLines.count, nextLines.count)

      // ステップ1: 差分のある行のみ更新
      for r in 0..<common where prevLines[r] != nextLines[r] {
        mv(r)  // カーソルを該当行に移動
        clr()  // 行をクリア
        print(nextLines[r], terminator: "")  // 新しい内容を出力
      }

      // ステップ2: 新しい行を追加（画面が拡張された場合）
      if nextLines.count > prevLines.count {
        for r in prevLines.count..<nextLines.count {
          mv(r)
          clr()
          print(nextLines[r], terminator: "")
        }
      } else if nextLines.count < prevLines.count {
        // ステップ3: 余分な行をクリア（画面が縮小された場合）
        for r in nextLines.count..<prevLines.count {
          mv(r)
          clr()  // 行全体をクリア
        }
      }

      // カーソルを最終行の次に移動（入力位置）
      mv(nextLines.count)
    } else {
      // 初回は全描画（前回のバッファがない場合）
      for (index, line) in nextLines.enumerated() {
        mv(index)
        print(line, terminator: "")
      }
    }

    // 出力を即座に反映
    // 差分更新でも即座の反映が重要（ちらつき防止）
    fflush(stdout)

    // 現在のバッファを保存
    prevCellBuffer = nextBuffer
  }

  // --- ヘルパーメソッド（ANSIエスケープシーケンス） ----------------

  /// カーソルを指定行に移動
  ///
  /// - Parameter r: 行番号（0ベース）
  ///
  /// ANSIエスケープシーケンス：ESC[行;列H
  /// 注：ターミナルでは行番号は1から始まるため、+1している
  private static func mv(_ r: Int) {
    print("\u{1B}[\(r + 1);1H", terminator: "")
  }

  /// 現在の行をクリア
  ///
  /// ANSIエスケープシーケンス：ESC[2K
  /// カーソル位置は変わらず、その行の内容だけを消去
  private static func clr() {
    print("\u{1B}[2K", terminator: "")
  }

  /// キーボード入力処理を開始
  ///
  /// InputLoopを起動し、キーボードイベントをルートViewに配信します。
  /// これにより、ユーザーの操作がアプリケーションに伝わります。
  private static func startInput() {
    InputLoop.start { ev in
      // キーボードイベントをルートViewのhandleメソッドに渡す
      // Viewがイベントを処理すると、必要に応じてscheduleRedraw()が呼ばれる
      cachedRoot?.handle(event: ev)
    }
  }

  /// デバッグ用：CellBufferの内容をダンプ
  ///
  /// CellRenderLoop.DEBUG = true の時に使用
  /// バッファの各行を可視化して出力（デバッグ時に便利）
  private static func dump(_ buffer: CellBuffer) {
    print("---- CellBuffer Debug ----")
    let lines = buffer.toANSILines()
    for (index, line) in lines.enumerated() {
      print("\(index): [\(line)]")
    }
    print("-------------------------")
  }

  /// アプリケーションを正常終了
  ///
  /// このメソッドは、ESCキーやCtrl+Cなどで呼ばれます。
  /// 終了前に画面をクリーンアップして、ターミナルを正常な状態に戻します。
  ///
  /// 処理の流れ：
  /// 1. 入力ループを停止
  /// 2. カーソルを最終行の下に移動
  /// 3. 現在行をクリア
  /// 4. プロセスを終了
  public static func shutdown() {
    // キーボード入力処理を停止
    InputLoop.stop()

    // カーソルを画面の最下部に移動
    if let buffer = prevCellBuffer {
      mv(buffer.toANSILines().count)
    }

    // 現在行をクリア（プロンプトが正しく表示されるように）
    clr()

    // 出力を確実にフラッシュ
    fflush(stdout)

    // プロセスを正常終了（exit code: 0）
    // exit: プロセスを終了させる標準ライブラリ関数
    // 0: 正常終了を示す終了コード（EXIT_SUCCESS）
    //
    // exitの処理内容：
    // 1. atexitで登録された関数を逆順で実行
    // 2. すべてのストリームをフラッシュしてクローズ
    // 3. tmpfile()で作成した一時ファイルを削除
    // 4. _exit()を呼んでカーネルに制御を返す
    //
    // 代替案：
    // 1. _exit(0) / _Exit(0): 即座にプロセス終了
    //    欠点：クリーンアップ処理がスキップされる
    //    利点：シグナルハンドラ内では安全
    // 2. abort(): 異常終了（SIGABRT送信）
    //    欠点：コアダンプ生成、異常終了扱い
    // 3. quick_exit(): C11で追加された高速終了
    //    欠点：サポートが限定的、at_quick_exitの登録が必要
    // 4. return from main: main関数からの戻り
    //    欠点：深いコールスタックからは使えない
    // 選択理由：exit()は標準的で、必要なクリーンアップを実行し、
    //         どこからでも呼び出せる
    exit(0)
  }
}
