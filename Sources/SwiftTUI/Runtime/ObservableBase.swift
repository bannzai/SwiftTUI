import Foundation

/// ObservableObjectの便利な基底クラス
/// 
/// このクラスを継承することで、@Publishedプロパティが自動的に
/// objectWillChange Publisherと連携するようになる。
///
/// 使用例：
/// ```swift
/// class UserModel: ObservableBase {
///     @Published var name = "Guest"
///     @Published var age = 0
///     
///     func birthday() {
///         age += 1  // 自動的にobjectWillChangeが発行される
///     }
/// }
/// ```
open class ObservableBase: ObservableObject, PublishedObservable {
    /// 変更通知Publisher
    public let objectWillChange = ObservableObjectPublisher()
    
    public init() {
        // リフレクションを使用して@Publishedプロパティを設定
        setupPublishedProperties()
    }
    
    /// 手動で変更通知を送信したい場合に使用
    public func notifyChange() {
        objectWillChange.send()
    }
}

/// ObservableObjectを手動で実装する場合のヘルパー
///
/// ObservableBaseを継承できない場合（他のクラスを継承している場合など）に
/// このヘルパーを使用して必要な機能を追加できる。
///
/// 使用例：
/// ```swift
/// class CustomModel: SomeOtherClass, ObservableObject {
///     let objectWillChange = ObservableObjectPublisher()
///     @Published var value = 0
///     
///     override init() {
///         super.init()
///         ObservableSetup.setupPublished(self)
///     }
/// }
/// ```
public enum ObservableSetup {
    /// ObservableObjectに@Publishedプロパティを設定
    public static func setupPublished<T: ObservableObject & PublishedObservable>(_ object: T) {
        object.setupPublishedProperties()
    }
}
