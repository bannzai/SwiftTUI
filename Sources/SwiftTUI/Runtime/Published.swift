import Foundation

/// SwiftUIの@Publishedプロパティラッパーに相当
/// ObservableObjectのプロパティ変更を自動的に通知
@propertyWrapper
public struct Published<Value> {
    /// 内部ストレージクラス
    final class Storage {
        var value: Value
        weak var publisher: ObservableObjectPublisher?
        
        init(value: Value) {
            self.value = value
        }
        
        func update(_ newValue: Value) {
            value = newValue
            publisher?.send()
        }
    }
    
    private let storage: Storage
    
    public init(wrappedValue: Value) {
        self.storage = Storage(value: wrappedValue)
    }
    
    /// プロパティの値
    public var wrappedValue: Value {
        get { storage.value }
        nonmutating set { storage.update(newValue) }
    }
    
    /// プロパティラッパーのプロジェクション
    public var projectedValue: Published<Value> {
        self
    }
}

/// Publishedプロパティを持つ型で自動的にPublisherを設定するプロトコル
public protocol PublishedObservable: ObservableObject {
    func setupPublishedProperties()
}

/// リフレクションを使用してPublishedプロパティを検出し、Publisherを設定
public extension PublishedObservable {
    func setupPublishedProperties() {
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            // プロパティラッパーの内部ストレージを探す
            if let publishedWrapper = child.value as? AnyPublishedWrapper {
                publishedWrapper.setPublisher(objectWillChange)
            }
            // @Publishedプロパティの場合、_propertyNameという形式でアクセス
            else if let propertyWrapper = Mirror(reflecting: child.value).children.first?.value as? AnyPublishedWrapper {
                propertyWrapper.setPublisher(objectWillChange)
            }
        }
    }
}

/// Type erasure用のプロトコル
private protocol AnyPublishedWrapper {
    func setPublisher(_ publisher: ObservableObjectPublisher)
}

extension Published: AnyPublishedWrapper {
    fileprivate func setPublisher(_ publisher: ObservableObjectPublisher) {
        storage.publisher = publisher
    }
}
