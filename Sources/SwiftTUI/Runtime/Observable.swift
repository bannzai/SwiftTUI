import Foundation

/// SwiftTUI独自のObservableプロトコル
///
/// ## 背景と設計判断
/// Swift標準ライブラリのObservation framework (iOS 17+)の調査結果：
/// 1. Observableは「マーカープロトコル」として定義されている
/// 2. 実際の実装は@Observableマクロがコンパイル時に生成する
/// 3. 手動での実装方法は公開されていない
/// 4. SwiftUIとの密結合な設計になっている
///
/// SwiftTUIが独自のObservableを実装する理由：
/// - マクロに依存しない明示的な実装が必要
/// - TUI環境に最適化された状態管理が必要
/// - SwiftUIライクでありながら、ターミナル環境に適した設計が必要
///
/// ## 将来的な標準Observable採用の判断基準
/// 以下の条件が満たされた場合、標準Observableへの移行を検討：
/// 1. 手動実装のドキュメントが公開される
/// 2. マクロ非依存の実装方法が提供される
/// 3. SwiftUI以外のフレームワークでの使用が想定された設計になる
/// 4. パフォーマンスやメモリ効率で明確な優位性が示される
///
/// 予想される実装方法（標準Observableを使う場合）：
/// - @Observableマクロを使用してモデルクラスを定義
/// - ObservationTracking APIを使用して変更を検知
/// - withObservationTracking { }ブロックで変更をトラッキング
/// - ただし現時点ではTUI環境での動作は未検証
///
/// ## 使用方法
/// WWDC23のObservation patternに従い、プロパティ変更時に手動で通知します：
/// ```swift
/// // Observableクラスの定義
/// class UserModel: Observable {
///     var name = "Guest" {
///         didSet { notifyChange() }
///     }
///     var age = 0 {
///         didSet { notifyChange() }
///     }
/// }
///
/// // Environmentでの共有
/// struct ContentView: View {
///     @Environment(UserModel.self) var userModel
///     
///     var body: some View {
///         Text("\(userModel.name), age: \(userModel.age)")
///     }
/// }
///
/// // アプリケーションのエントリーポイント
/// let userModel = UserModel()
/// SwiftTUI.run(ContentView()
///     .environment(userModel))
/// ```
public protocol Observable: AnyObject {
    /// 変更通知を送信
    func notifyChange()
}

/// Observableのデフォルト実装
public extension Observable {
    func notifyChange() {
        // デフォルトではCellRenderLoopに再描画をスケジュール
        CellRenderLoop.scheduleRedraw()
    }
}