import Foundation
#if canImport(Observation)
import Observation
#endif

/// Swift標準のObservation frameworkとの統合をサポート
///
/// ## 概要
/// このファイルは、Swift 5.9+で導入されたObservation frameworkの
/// Observableプロトコルを、SwiftTUIで使用できるようにするためのブリッジング層を提供します。
///
/// ## 使用方法
/// ```swift
/// // @Observableマクロを使用（Swift 5.9+）
/// @Observable
/// class UserModel {
///     var name = "Guest"
///     var age = 0
/// }
///
/// // SwiftTUIでの使用
/// struct ContentView: View {
///     @Environment(UserModel.self) var user
///
///     var body: some View {
///         Text("\(user.name), age: \(user.age)")
///     }
/// }
/// ```

#if canImport(Observation)

/// Observationトラッキングを管理するクラス
@MainActor
internal final class ObservationTracker {
    static let shared = ObservationTracker()
    
    private var activeTrackers: [ObjectIdentifier: TrackerInfo] = [:]
    
    private struct TrackerInfo {
        let object: AnyObject
        var accessClosure: (() -> Void)?
    }
    
    /// Observableオブジェクトのトラッキングを開始
    func startTracking(_ object: AnyObject, accessClosure: @escaping () -> Void) {
        let id = ObjectIdentifier(object)
        activeTrackers[id] = TrackerInfo(object: object, accessClosure: accessClosure)
        
        // 初回のトラッキングを開始
        performTracking(for: id)
    }
    
    /// Observableオブジェクトのトラッキングを停止
    func stopTracking(_ object: AnyObject) {
        let id = ObjectIdentifier(object)
        activeTrackers.removeValue(forKey: id)
    }
    
    private func performTracking(for id: ObjectIdentifier) {
        guard let trackerInfo = activeTrackers[id] else { return }
        
        Task { @MainActor in
            await withObservationTracking {
                // アクセスクロージャを実行してプロパティアクセスをトリガー
                trackerInfo.accessClosure?()
            } onChange: {
                // 変更が検出されたら再描画をスケジュール
                CellRenderLoop.scheduleRedraw()
                
                // 再度トラッキングを開始
                Task { @MainActor in
                    self.performTracking(for: id)
                }
            }
        }
    }
}

/// SwiftTUIのObservableと標準Observableの両方をサポートする型消去ラッパー
public struct AnyObservableBox {
    enum Storage {
        case swiftTUI(any Observable)
        case standard(any Observation.Observable)
    }
    
    private let storage: Storage
    private let id: ObjectIdentifier
    
    /// SwiftTUIのObservableから初期化
    public init(_ observable: any Observable) {
        self.storage = .swiftTUI(observable)
        self.id = ObjectIdentifier(observable)
    }
    
    /// 標準のObservableから初期化
    public init(_ observable: any Observation.Observable) {
        self.storage = .standard(observable)
        self.id = ObjectIdentifier(observable as AnyObject)
    }
    
    /// 元のオブジェクトを取得
    public var wrappedValue: Any {
        switch storage {
        case .swiftTUI(let observable):
            return observable
        case .standard(let observable):
            return observable
        }
    }
    
    /// Observationトラッキングを開始
    @MainActor
    public func startTracking(accessClosure: @escaping () -> Void) {
        switch storage {
        case .swiftTUI:
            // SwiftTUI Observableは手動でnotifyChange()を呼び出す
            break
        case .standard(let observable):
            // 標準ObservableはObservationTrackerでトラッキング
            ObservationTracker.shared.startTracking(observable as AnyObject, accessClosure: accessClosure)
        }
    }
    
    /// Observationトラッキングを停止
    @MainActor
    public func stopTracking() {
        switch storage {
        case .swiftTUI:
            break
        case .standard(let observable):
            ObservationTracker.shared.stopTracking(observable as AnyObject)
        }
    }
}

#else

/// Swift 5.9未満の環境用のダミー実装
public struct AnyObservableBox {
    private let observable: any Observable
    
    public init(_ observable: any Observable) {
        self.observable = observable
    }
    
    public var wrappedValue: Any {
        return observable
    }
}

#endif