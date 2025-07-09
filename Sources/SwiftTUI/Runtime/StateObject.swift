import Foundation

/// ObservableObjectのインスタンスを所有し、変更を監視するプロパティラッパー
///
/// SwiftUIの@StateObjectに相当する機能を提供。
/// @ObservableStateとの違いは、StateObjectはObservableObjectの
/// ライフサイクルを管理し、Viewの再作成時でも同じインスタンスを保持する。
///
/// 使用例：
/// ```swift
/// struct UserView: View {
///     @StateObject private var userModel = UserModel()
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
public struct StateObject<ObjectType: ObservableObject> {
    /// 内部ストレージ
    final class Storage {
        private var object: ObjectType?
        private let makeObject: () -> ObjectType
        private var cancellable: (() -> Void)?
        
        init(makeObject: @escaping () -> ObjectType) {
            self.makeObject = makeObject
        }
        
        deinit {
            cancellable?()
        }
        
        var wrappedValue: ObjectType {
            if let object = object {
                return object
            }
            
            // 初回アクセス時にオブジェクトを作成
            let newObject = makeObject()
            self.object = newObject
            setupObservation(for: newObject)
            return newObject
        }
        
        func binding<Value>(for keyPath: WritableKeyPath<ObjectType, Value>) -> Binding<Value> {
            Binding(
                get: { 
                    // wrappedValueを通じてオブジェクトを取得（必要に応じて作成）
                    self.wrappedValue[keyPath: keyPath] 
                },
                set: { newValue in
                    // 現在のオブジェクトに直接アクセス
                    if self.object == nil {
                        _ = self.wrappedValue // オブジェクトを作成
                    }
                    self.object?[keyPath: keyPath] = newValue
                }
            )
        }
        
        
        private func setupObservation(for object: ObjectType) {
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
    }
    
    private let storage: Storage
    
    /// デフォルト値から初期化
    public init(wrappedValue: @escaping @autoclosure () -> ObjectType) {
        self.storage = Storage(makeObject: wrappedValue)
    }
    
    /// プロパティの値（ObservableObject）
    public var wrappedValue: ObjectType {
        storage.wrappedValue
    }
    
    /// StateObjectのプロジェクション
    public var projectedValue: StateObject<ObjectType> {
        self
    }
    
    /// 動的メンバールックアップでObservableObjectのプロパティへのBindingを提供
    public subscript<Value>(dynamicMember keyPath: WritableKeyPath<ObjectType, Value>) -> Binding<Value> {
        storage.binding(for: keyPath)
    }
}

