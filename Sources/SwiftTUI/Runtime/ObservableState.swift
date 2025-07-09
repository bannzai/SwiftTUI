import Foundation

/// ObservableObjectの変更を監視し、Viewの再描画をトリガーするプロパティラッパー
///
/// SwiftUIの@ObservedObjectに相当する機能を提供。
/// ObservableObjectのobjectWillChange通知を受け取って、
/// 自動的にViewの再描画をスケジュールする。
///
/// 使用例：
/// ```swift
/// struct UserView: View {
///     @ObservableState var userModel = UserModel()
///     
///     var body: some View {
///         VStack {
///             Text("Name: \(userModel.name)")
///             Button("Change Name") {
///                 userModel.name = "New Name"  // 自動的にViewが再描画される
///             }
///         }
///     }
/// }
/// ```
@propertyWrapper
@dynamicMemberLookup
public struct ObservableState<ObjectType: ObservableObject> {
    /// 内部ストレージ
    final class Storage {
        var object: ObjectType
        private var cancellable: (() -> Void)?
        
        init(_ object: ObjectType) {
            self.object = object
            setupObservation()
        }
        
        deinit {
            cancellable?()
        }
        
        private func setupObservation() {
            // ObservableObjectの変更を監視
            object.objectWillChange.addObserver { [weak self] in
                // Viewの再描画はすでにPublisher内でスケジュールされている
                // ここでは追加の処理は不要
            }
            
            // クリーンアップ用のクロージャを保存
            cancellable = { [weak object] in
                // 現在のPublisher実装では明示的なクリーンアップは不要
                // 将来的に必要になった場合のためのプレースホルダー
            }
        }
        
        func update(_ newObject: ObjectType) {
            // 古いオブジェクトの監視を解除
            cancellable?()
            
            // 新しいオブジェクトを設定
            object = newObject
            setupObservation()
            
            // 変更を通知
            CellRenderLoop.scheduleRedraw()
        }
    }
    
    private let storage: Storage
    
    public init(wrappedValue: ObjectType) {
        self.storage = Storage(wrappedValue)
    }
    
    /// プロパティの値（ObservableObject）
    public var wrappedValue: ObjectType {
        get { storage.object }
        nonmutating set { storage.update(newValue) }
    }
    
    /// ObservableStateのプロジェクション
    public var projectedValue: ObservableState<ObjectType> {
        self
    }
    
    /// 動的メンバールックアップでObservableObjectのプロパティへのBindingを提供
    ///
    /// 使用例：
    /// ```swift
    /// TextField("Name", text: $userModel.name)
    /// ```
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<ObjectType, Value>) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue[keyPath: keyPath] },
            set: { self.wrappedValue[keyPath: keyPath] = $0 }
        )
    }
}

