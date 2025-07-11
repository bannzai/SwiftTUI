import Foundation
#if canImport(Observation)
import Observation
#endif

/// 環境値にアクセスするためのプロパティラッパー
///
/// SwiftUIの@Environmentに相当する機能を提供。
/// View階層を通じて伝播される環境値にアクセスできる。
///
/// 使用例：
/// ```swift
/// struct ContentView: View {
///     @Environment(\.foregroundColor) var textColor
///     @Environment(\.isEnabled) var isEnabled
///     
///     var body: some View {
///         Text("Hello")
///             .foregroundColor(textColor)
///             .opacity(isEnabled ? 1.0 : 0.5)
///     }
/// }
/// ```
///
/// Observable型の使用例：
/// ```swift
/// class UserModel: Observable {
///     @Published var name = "Guest"
/// }
///
/// struct ContentView: View {
///     @Environment(UserModel.self) var userModel: UserModel?
///     
///     var body: some View {
///         if let userModel = userModel {
///             Text("Hello, \(userModel.name)")
///         } else {
///             Text("No user model")
///         }
///     }
/// }
/// ```
@propertyWrapper
public struct Environment<Value> {
    /// 環境値の取得方法
    private enum Source {
        case keyPath(KeyPath<EnvironmentValues, Value>)
        // TODO: 将来的に削除予定 - 標準@Observableへの完全移行時
        case swiftTUIObservableType(Observable.Type)
        #if canImport(Observation)
        case standardObservableType(any Observation.Observable.Type)
        #endif
    }
    
    private let source: Source
    
    /// キーパスを指定して初期化
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.source = .keyPath(keyPath)
    }
    
    /// SwiftTUIのObservable型を指定して初期化
    // TODO: 将来的に削除予定 - 標準@Observableへの完全移行時
    public init<T>(_ type: T.Type) where T: Observable, Value == T? {
        self.source = .swiftTUIObservableType(type)
    }
    
    #if canImport(Observation)
    /// 標準のObservable型を指定して初期化
    public init<T>(_ type: T.Type) where T: Observation.Observable, Value == T? {
        self.source = .standardObservableType(type)
    }
    #endif
    
    /// 環境値の取得
    public var wrappedValue: Value {
        switch source {
        case .keyPath(let keyPath):
            return EnvironmentValues.current[keyPath: keyPath]
        case .swiftTUIObservableType(let type):
            // TODO: 将来的に削除予定 - 標準@Observableへの完全移行時
            // SwiftTUI Observable型の場合、EnvironmentValuesから取得
            let key = ObjectIdentifier(type)
            if let observable = EnvironmentValues.current.observables[key] {
                return observable as! Value
            } else {
                // Value は T? 型なので、nil を返す
                return Optional<Any>.none as! Value
            }
        #if canImport(Observation)
        case .standardObservableType(let type):
            // 標準Observable型の場合、EnvironmentValuesから取得
            let key = ObjectIdentifier(type)
            if let box = EnvironmentValues.current.observableBoxes[key] {
                return box.wrappedValue as! Value
            } else {
                // Value は T? 型なので、nil を返す
                return Optional<Any>.none as! Value
            }
        #endif
        }
    }
}

/// Viewに環境値を設定するためのModifier
public struct EnvironmentModifier<Content: View>: View {
    let content: Content
    let modifier: (inout EnvironmentValues) -> Void
    
    public var body: some View {
        // EnvironmentWrapperを使って環境値を保持
        EnvironmentWrapper(content: content, modifier: modifier)
    }
}

/// EnvironmentWrapperがLayoutViewを提供するためのプロトコル
internal protocol EnvironmentWrapperProtocol {
    var layoutView: any LayoutView { get }
}

/// 環境値を保持してレンダリング時に適用するラッパー
internal struct EnvironmentWrapper<Content: View>: View, EnvironmentWrapperProtocol {
    let content: Content
    let modifier: (inout EnvironmentValues) -> Void
    
    public typealias Body = Never
    
    internal var _layoutView: any LayoutView {
        EnvironmentWrapperLayoutView(content: content, modifier: modifier)
    }
    
    // プロトコル要件
    var layoutView: any LayoutView {
        return _layoutView
    }
}

/// EnvironmentWrapperのLayoutView実装
internal class EnvironmentWrapperLayoutView<Content: View>: LayoutView, CellLayoutView {
    let content: Content
    let modifier: (inout EnvironmentValues) -> Void
    private var contentLayoutView: (any LayoutView)?
    private var isContentCreated = false
    
    init(content: Content, modifier: @escaping (inout EnvironmentValues) -> Void) {
        self.content = content
        self.modifier = modifier
    }
    
    private func ensureContentLayoutView() {
        guard !isContentCreated else { return }
        isContentCreated = true
        
        // 環境値を適用してcontentのLayoutViewを作成
        var newEnvironment = EnvironmentValues.current
        modifier(&newEnvironment)
        
        let oldEnvironment = EnvironmentValues.current
        EnvironmentValues.current = newEnvironment
        defer { EnvironmentValues.current = oldEnvironment }
        
        contentLayoutView = ViewRenderer.renderView(content)
    }
    
    func makeNode() -> YogaNode {
        ensureContentLayoutView()
        return contentLayoutView?.makeNode() ?? YogaNode()
    }
    
    func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
        ensureContentLayoutView()
        
        // 環境値を適用してペイント
        var newEnvironment = EnvironmentValues.current
        modifier(&newEnvironment)
        
        let oldEnvironment = EnvironmentValues.current
        EnvironmentValues.current = newEnvironment
        defer { EnvironmentValues.current = oldEnvironment }
        
        contentLayoutView?.paint(origin: origin, into: &buffer)
    }
    
    func render(into buffer: inout [String]) {
        ensureContentLayoutView()
        
        // 環境値を適用してレンダリング
        var newEnvironment = EnvironmentValues.current
        modifier(&newEnvironment)
        
        let oldEnvironment = EnvironmentValues.current
        EnvironmentValues.current = newEnvironment
        defer { EnvironmentValues.current = oldEnvironment }
        
        contentLayoutView?.render(into: &buffer)
    }
    
    // MARK: - CellLayoutView
    
    func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
        ensureContentLayoutView()
        
        // 環境値を適用してセルペイント
        var newEnvironment = EnvironmentValues.current
        modifier(&newEnvironment)
        
        let oldEnvironment = EnvironmentValues.current
        EnvironmentValues.current = newEnvironment
        defer { EnvironmentValues.current = oldEnvironment }
        
        if let cellLayoutView = contentLayoutView as? CellLayoutView {
            cellLayoutView.paintCells(origin: origin, into: &buffer)
        } else {
            // CellLayoutViewでない場合は通常のpaintを使用
            var stringBuffer: [String] = []
            contentLayoutView?.paint(origin: origin, into: &stringBuffer)
            // TODO: stringBufferからCellBufferへの変換が必要
        }
    }
}

/// Viewに環境値を設定するための拡張
public extension View {
    /// 環境値を設定
    ///
    /// 使用例：
    /// ```swift
    /// VStack {
    ///     // 子Viewはすべて赤色のテキストになる
    ///     Text("Red Text")
    ///     Text("Also Red")
    /// }
    /// .environment(\.foregroundColor, .red)
    /// ```
    func environment<Value>(
        _ keyPath: WritableKeyPath<EnvironmentValues, Value>,
        _ value: Value
    ) -> some View {
        EnvironmentModifier(content: self) { environment in
            environment[keyPath: keyPath] = value
        }
    }
    
    /// SwiftTUIのObservable型を環境に設定
    // TODO: 将来的に削除予定 - 標準@Observableへの完全移行時
    ///
    /// 使用例：
    /// ```swift
    /// let userModel = UserModel()
    /// 
    /// ContentView()
    ///     .environment(userModel)
    /// ```
    func environment<T: Observable>(_ observable: T) -> some View {
        EnvironmentModifier(content: self) { environment in
            let key = ObjectIdentifier(type(of: observable))
            environment.observables[key] = observable
        }
    }
    
    #if canImport(Observation)
    /// 標準のObservable型を環境に設定
    ///
    /// 使用例：
    /// ```swift
    /// @Observable
    /// class UserModel {
    ///     var name = "Guest"
    /// }
    /// 
    /// let userModel = UserModel()
    /// ContentView()
    ///     .environment(userModel)
    /// ```
    func environment<T: Observation.Observable>(_ observable: T) -> some View {
        EnvironmentModifier(content: self) { environment in
            let key = ObjectIdentifier(type(of: observable))
            let box = AnyObservableBox(observable)
            environment.observableBoxes[key] = box
        }
    }
    #endif
    
    /// 無効状態を設定
    func disabled(_ disabled: Bool = true) -> some View {
        environment(\.isEnabled, !disabled)
    }
}