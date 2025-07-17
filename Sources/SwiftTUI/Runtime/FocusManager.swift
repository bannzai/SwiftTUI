/// FocusManager：TUIアプリケーションのフォーカス管理システム
///
/// TUIにおけるキーボードナビゲーションを管理する中核コンポーネントです。
/// Tabキーでのフォーカス移動、キーボードイベントの配信、
/// 再レンダリング時のフォーカス保持などを担当します。
///
/// TUI初心者向け解説：
/// - GUIではマウスクリックで要素を選択
/// - TUIではTabキーで要素間を移動
/// - フォーカスされた要素のみキー入力を受け付ける
///
/// シングルトンパターン：
/// - アプリケーション全体で1つのFocusManager
/// - すべてのフォーカス可能要素を一元管理

import Darwin

/// フォーカス管理システム
internal class FocusManager {
  /// シングルトンインスタンス
  static let shared = FocusManager()

  /// 現在登録されているフォーカス可能なViewのリスト
  /// Tabキーでのナビゲーション順序を定義
  private var focusableViews: [FocusableViewInfo] = []

  /// 現在フォーカスされているViewのインデックス
  /// nilの場合はフォーカスなし
  private var currentFocusIndex: Int? = nil

  /// 再レンダリング中かどうかのフラグ
  /// 再レンダリング中は自動フォーカスを抑制
  private var isRerendering = false

  /// プライベートイニシャライザ（シングルトンのため）
  private init() {}

  /// フォーカス可能なViewの情報
  ///
  /// 各フォーカス可能要素の情報を保持する構造体です。
  ///
  /// weak参照の説明：
  /// - handlerをweakで保持して循環参照を回避
  /// - Viewが破棄されたら自動的にnilになる
  struct FocusableViewInfo {
    /// Viewの一意識別子
    let id: String

    /// キーボード入力を受け付けるか
    /// true: TextFieldなどの入力フィールド
    /// false: Buttonなどの操作要素
    let acceptsInput: Bool

    /// FocusableViewプロトコルを実装したViewへの弱参照
    weak var handler: FocusableView?
  }

  /// フォーカス可能なViewを登録
  ///
  /// Viewが描画されるたびに呼ばれ、フォーカス管理リストに追加します。
  /// 同じIDのViewが既に存在する場合は置き換えます。
  ///
  /// - Parameters:
  ///   - view: 登録するView（FocusableViewプロトコルを実装）
  ///   - id: Viewの一意識別子
  ///   - acceptsInput: キーボード入力を受け付けるか
  ///
  /// フォーカス復元の仕組み：
  /// - 再レンダリング時にViewが破棄・再作成される
  /// - savedFocusIDで以前のフォーカスを記憶
  /// - 同じIDのViewが再登録されたらフォーカスを復元
  func register(_ view: FocusableView, id: String, acceptsInput: Bool = false) {
    // 既存の同じIDを削除
    // 同じViewが二重登録されるのを防ぐ
    focusableViews.removeAll { $0.id == id }

    let info = FocusableViewInfo(id: id, acceptsInput: acceptsInput, handler: view)
    focusableViews.append(info)

    // フォーカスを復元または初期設定
    if let focusedID = savedFocusID,
      let newIndex = focusableViews.firstIndex(where: { $0.id == focusedID })
    {
      // 以前フォーカスされていたViewが再登録された場合、フォーカスを復元
      currentFocusIndex = newIndex
      updateFocusState()
    } else if currentFocusIndex == nil && !focusableViews.isEmpty && !isRerendering {
      // 再レンダリング中でない場合のみ、最初のViewにフォーカスを設定
      // アプリ起動時に最初の要素に自動フォーカス
      currentFocusIndex = 0
      updateFocusState()
    }
  }

  /// フォーカス可能なViewを削除
  func unregister(id: String) {
    focusableViews.removeAll { $0.id == id }

    // フォーカスインデックスの調整
    if let index = currentFocusIndex, index >= focusableViews.count {
      currentFocusIndex = focusableViews.isEmpty ? nil : focusableViews.count - 1
      updateFocusState()
    }
  }

  /// 次のViewにフォーカスを移動
  ///
  /// Tabキーが押されたときに呼ばれ、次の要素にフォーカスを移動します。
  /// 最後の要素の次は最初の要素に戻ります（循環）。
  ///
  /// 処理の流れ：
  /// 1. 現在のインデックスに1を加算
  /// 2. リストの範囲を超えたら0に戻る（%演算子）
  /// 3. フォーカス状態を更新
  /// 4. 画面を再描画
  func focusNext() {
    guard !focusableViews.isEmpty else { return }

    if let index = currentFocusIndex {
      // 次のインデックスを計算（循環）
      currentFocusIndex = (index + 1) % focusableViews.count
    } else {
      // フォーカスがない場合は最初の要素に設定
      currentFocusIndex = 0
    }

    updateFocusState()

    // フォーカスの変更を反映するため再描画をスケジュール
    CellRenderLoop.scheduleRedraw()
  }

  /// 前のViewにフォーカスを移動
  func focusPrevious() {
    guard !focusableViews.isEmpty else { return }

    if let index = currentFocusIndex {
      currentFocusIndex = index > 0 ? index - 1 : focusableViews.count - 1
    } else {
      currentFocusIndex = focusableViews.count - 1
    }

    updateFocusState()
    CellRenderLoop.scheduleRedraw()
  }

  /// 現在フォーカスされているViewのIDを取得
  func currentFocusedID() -> String? {
    guard let index = currentFocusIndex,
      index < focusableViews.count
    else { return nil }
    return focusableViews[index].id
  }

  /// 現在フォーカスされているViewが入力を受け付けるか
  func currentAcceptsInput() -> Bool {
    guard let index = currentFocusIndex,
      index < focusableViews.count
    else { return false }
    return focusableViews[index].acceptsInput
  }

  /// キーボードイベントを処理
  ///
  /// InputLoopから呼ばれ、キーボードイベントを適切なViewに配信します。
  /// Tabキーはフォーカス移動、それ以外はフォーカスされたViewに転送します。
  ///
  /// - Parameter event: キーボードイベント
  /// - Returns: イベントを処理したかtrue
  ///
  /// 処理の流れ：
  /// 1. Tabキーをチェック→フォーカス移動
  /// 2. フォーカスされたViewがあるか確認
  /// 3. あればそのViewにhandleKeyEventを呼び出し
  func handleKeyEvent(_ event: KeyboardEvent) -> Bool {
    // Tabでフォーカス移動
    // TODO: Shift+Tabで逆方向移動の実装
    if event.key == .tab {
      focusNext()
      return true
    }

    // 現在フォーカスされているViewにイベントを転送
    if let index = currentFocusIndex,
      index < focusableViews.count,
      let handler = focusableViews[index].handler
    {
      // フォーカスされたViewがイベントを処理
      return handler.handleKeyEvent(event)
    }

    return false
  }

  /// フォーカス状態を更新
  ///
  /// すべてのフォーカス可能なViewに対して、
  /// フォーカスされているかどうかを通知します。
  ///
  /// Viewへの通知：
  /// - フォーカスあり: setFocused(true)
  /// - フォーカスなし: setFocused(false)
  /// - Viewはこれに応じて表示を変更（枠線の色など）
  private func updateFocusState() {
    for (index, info) in focusableViews.enumerated() {
      let shouldBeFocused = index == currentFocusIndex
      // weak参照なのでnilチェックが必要
      info.handler?.setFocused(shouldBeFocused)
    }
  }

  /// すべてのフォーカス情報をクリア
  func reset() {
    focusableViews.removeAll()
    currentFocusIndex = nil
    isRerendering = false
  }

  /// レンダリング完了を通知
  func finishRerendering() {
    isRerendering = false
    // 保存されたフォーカスIDに基づいてフォーカスを復元
    if let focusedID = savedFocusID,
      let index = focusableViews.firstIndex(where: { $0.id == focusedID })
    {
      currentFocusIndex = index
      updateFocusState()
    } else if currentFocusIndex == nil && !focusableViews.isEmpty {
      // フォーカスが設定されていない場合は最初のViewにフォーカス
      currentFocusIndex = 0
      updateFocusState()
    }
  }

  /// 再レンダリング時にフォーカスを保存するための変数
  private var savedFocusID: String?

  /// レンダリング前の準備（現在のフォーカスIDを保持してViewリストをクリア）
  ///
  /// CellRenderLoopから呼ばれ、再レンダリングの準備をします。
  /// Viewは破棄・再作成されるため、フォーカス情報を一時保存します。
  ///
  /// 処理の流れ：
  /// 1. 再レンダリングフラグをON
  /// 2. 現在フォーカスされているViewのIDを保存
  /// 3. すべてのView情報をクリア
  /// 4. finishRerendering()でフォーカスを復元
  func prepareForRerender() {
    isRerendering = true

    // 現在フォーカスされているViewのIDを保持
    if let index = currentFocusIndex,
      index < focusableViews.count
    {
      savedFocusID = focusableViews[index].id
    }

    // すべてのViewをクリアするが、フォーカス情報は保持
    focusableViews.removeAll()
    currentFocusIndex = nil
  }

  /// デバッグ情報の出力
  func debugPrint() {
    print("[FocusManager] === DEBUG INFO ===")
    print("[FocusManager] Total views: \(focusableViews.count)")
    print("[FocusManager] Current focus index: \(String(describing: currentFocusIndex))")
    for (index, view) in focusableViews.enumerated() {
      print("[FocusManager] [\(index)] \(view.id) - handler: \(view.handler != nil)")
    }
    print("[FocusManager] ==================")
  }
}

/// フォーカス可能なViewのプロトコル
///
/// フォーカスを受け取り、キーボードイベントを処理できるViewが
/// 実装すべきプロトコルです。
///
/// 実装例：
/// - Button: Enter/Spaceでアクション実行
/// - TextField: 文字入力やカーソル移動
/// - Toggle: SpaceでON/OFF切り替え
///
/// AnyObjectの説明：
/// - クラス型のみが実装可能
/// - weak参照が必要なため
internal protocol FocusableView: AnyObject {
  /// フォーカス状態を設定
  ///
  /// FocusManagerから呼ばれ、フォーカス状態を更新します。
  /// Viewはこれに応じて表示を変更します（枠線の色など）。
  ///
  /// - Parameter focused: true = フォーカスあり、false = フォーカスなし
  func setFocused(_ focused: Bool)

  /// キーボードイベントを処理
  ///
  /// フォーカスがあるときにキーボードイベントを受け取ります。
  /// 各Viewは必要なキーイベントを処理し、
  /// 処理した場合はtrueを返します。
  ///
  /// - Parameter event: キーボードイベント
  /// - Returns: イベントを処理したかtrue
  func handleKeyEvent(_ event: KeyboardEvent) -> Bool

  /// 再レンダリング前の準備（オプション）
  ///
  /// 再レンダリング前に状態をクリアする必要がある場合に実装します。
  /// デフォルト実装が提供されるため、必須ではありません。
  func prepareForRerender()
}

// デフォルト実装を提供
/// FocusableViewのデフォルト実装
///
/// prepareForRerenderはオプションなので、
/// 必要ないViewは実装しなくても良いようにします。
extension FocusableView {
  func prepareForRerender() {
    // デフォルトでは何もしない
  }
}
