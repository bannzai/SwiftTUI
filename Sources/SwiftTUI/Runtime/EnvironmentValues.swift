import Foundation

/// 環境値を格納するコンテナ
///
/// SwiftUIのEnvironmentValuesに相当する機能を提供。
/// View階層を通じて値を伝播するための仕組み。
///
/// カスタム環境値の定義例：
/// ```swift
/// private struct ThemeKey: EnvironmentKey {
///     static let defaultValue = Theme.light
/// }
/// 
/// extension EnvironmentValues {
///     var theme: Theme {
///         get { self[ThemeKey.self] }
///         set { self[ThemeKey.self] = newValue }
///     }
/// }
/// ```
public struct EnvironmentValues {
    /// 内部ストレージ
    private var storage: [ObjectIdentifier: Any] = [:]
    
    /// 現在の環境値（グローバル）
    internal static var current = EnvironmentValues()
    
    public init() {}
    
    /// 環境値へのアクセス
    public subscript<K: EnvironmentKey>(key: K.Type) -> K.Value {
        get {
            storage[ObjectIdentifier(key)] as? K.Value ?? K.defaultValue
        }
        set {
            storage[ObjectIdentifier(key)] = newValue
        }
    }
}

/// 環境値のキーを定義するためのプロトコル
public protocol EnvironmentKey {
    /// 値の型
    associatedtype Value
    
    /// デフォルト値
    static var defaultValue: Value { get }
}

// MARK: - 組み込み環境値

/// フォントサイズのキー
private struct FontSizeKey: EnvironmentKey {
    static let defaultValue: Int = 16
}

/// テキスト色のキー
private struct ForegroundColorKey: EnvironmentKey {
    static let defaultValue: Color = .white
}

/// 背景色のキー
private struct BackgroundColorKey: EnvironmentKey {
    static let defaultValue: Color = .black
}

/// 無効状態のキー
private struct IsEnabledKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

/// 組み込み環境値へのアクセス
public extension EnvironmentValues {
    /// フォントサイズ
    var fontSize: Int {
        get { self[FontSizeKey.self] }
        set { self[FontSizeKey.self] = newValue }
    }
    
    /// テキスト色
    var foregroundColor: Color {
        get { self[ForegroundColorKey.self] }
        set { self[ForegroundColorKey.self] = newValue }
    }
    
    /// 背景色
    var backgroundColor: Color {
        get { self[BackgroundColorKey.self] }
        set { self[BackgroundColorKey.self] = newValue }
    }
    
    /// 無効状態
    var isEnabled: Bool {
        get { self[IsEnabledKey.self] }
        set { self[IsEnabledKey.self] = newValue }
    }
}
