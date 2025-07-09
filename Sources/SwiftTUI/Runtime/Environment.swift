import Foundation

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
@propertyWrapper
public struct Environment<Value> {
    /// キーパス
    private let keyPath: KeyPath<EnvironmentValues, Value>
    
    /// キーパスを指定して初期化
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }
    
    /// 環境値の取得
    public var wrappedValue: Value {
        EnvironmentValues.current[keyPath: keyPath]
    }
}

/// Viewに環境値を設定するためのModifier
public struct EnvironmentModifier<Content: View>: View {
    let content: Content
    let modifier: (inout EnvironmentValues) -> Void
    
    public var body: some View {
        // 現在の環境値をコピー
        var newEnvironment = EnvironmentValues.current
        
        // 変更を適用
        modifier(&newEnvironment)
        
        // 一時的に環境値を変更
        let oldEnvironment = EnvironmentValues.current
        EnvironmentValues.current = newEnvironment
        defer { EnvironmentValues.current = oldEnvironment }
        
        // コンテンツを返す
        return content
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
    
    /// 無効状態を設定
    func disabled(_ disabled: Bool = true) -> some View {
        environment(\.isEnabled, !disabled)
    }
}

/// EnvironmentObjectをView階層に伝播するためのラッパー
public struct EnvironmentObjectModifier<Content: View, Object: ObservableObject>: View {
    let content: Content
    let object: Object
    
    public var body: some View {
        // TODO: EnvironmentObjectの実装
        // 現在はプレースホルダー
        content
    }
}

/// EnvironmentObjectを設定するための拡張
public extension View {
    /// EnvironmentObjectを設定
    ///
    /// 使用例：
    /// ```swift
    /// struct MyApp: View {
    ///     @StateObject private var userModel = UserModel()
    ///     
    ///     var body: some View {
    ///         ContentView()
    ///             .environmentObject(userModel)
    ///     }
    /// }
    /// ```
    func environmentObject<Object: ObservableObject>(
        _ object: Object
    ) -> some View {
        EnvironmentObjectModifier(content: self, object: object)
    }
}
