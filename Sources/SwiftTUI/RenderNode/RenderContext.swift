/// RenderContext：レンダリング時のコンテキスト情報
///
/// このファイルには、RenderNode生成時に必要なコンテキスト情報を
/// 管理する型が定義されています。環境値、フォーカス状態、
/// アニメーション設定などを含みます。

import Foundation

/// レンダリングコンテキスト
///
/// ViewからRenderNodeへの変換時に、必要な環境情報を伝達します。
/// SwiftUIのEnvironmentと同様の役割を果たします。
public struct RenderContext {
  // MARK: - Properties
  
  /// 環境値
  public let environment: EnvironmentValues
  
  /// フォーカス状態
  public let focusState: FocusState
  
  /// アニメーション設定（将来の拡張用）
  public let animation: Animation?
  
  /// 再描画のトリガー
  public let redrawTrigger: () -> Void
  
  /// 現在の時刻（アニメーション用）
  public let currentTime: TimeInterval
  
  /// ノードのストレージ（状態保持用）
  private var nodeStorage: NodeStorage
  
  // MARK: - Initialization
  
  /// イニシャライザ
  public init(
    environment: EnvironmentValues = EnvironmentValues(),
    focusState: FocusState = FocusState(),
    animation: Animation? = nil,
    redrawTrigger: @escaping () -> Void = {},
    currentTime: TimeInterval = 0,
    nodeStorage: NodeStorage = NodeStorage()
  ) {
    self.environment = environment
    self.focusState = focusState
    self.animation = animation
    self.redrawTrigger = redrawTrigger
    self.currentTime = currentTime
    self.nodeStorage = nodeStorage
  }
  
  // MARK: - Context Modification
  
  /// 環境値を更新したコンテキストを返す
  public func with(environment: EnvironmentValues) -> RenderContext {
    RenderContext(
      environment: environment,
      focusState: focusState,
      animation: animation,
      redrawTrigger: redrawTrigger,
      currentTime: currentTime,
      nodeStorage: nodeStorage
    )
  }
  
  /// フォーカス状態を更新したコンテキストを返す
  public func with(focusState: FocusState) -> RenderContext {
    RenderContext(
      environment: environment,
      focusState: focusState,
      animation: animation,
      redrawTrigger: redrawTrigger,
      currentTime: currentTime,
      nodeStorage: nodeStorage
    )
  }
  
  /// アニメーションを設定したコンテキストを返す
  public func with(animation: Animation?) -> RenderContext {
    RenderContext(
      environment: environment,
      focusState: focusState,
      animation: animation,
      redrawTrigger: redrawTrigger,
      currentTime: currentTime,
      nodeStorage: nodeStorage
    )
  }
}

// MARK: - Focus State

/// フォーカス状態を管理する構造体
///
/// 現在フォーカスされているノードとフォーカス可能なノードのリストを管理します。
public struct FocusState {
  /// 現在フォーカスされているノードのID
  public var focusedNodeId: ObjectIdentifier?
  
  /// フォーカス可能なノードのIDリスト（順序付き）
  public var focusableNodes: [ObjectIdentifier] = []
  
  /// フォーカスが有効かどうか
  public var isEnabled: Bool = true
  
  /// イニシャライザ
  public init(
    focusedNodeId: ObjectIdentifier? = nil,
    focusableNodes: [ObjectIdentifier] = [],
    isEnabled: Bool = true
  ) {
    self.focusedNodeId = focusedNodeId
    self.focusableNodes = focusableNodes
    self.isEnabled = isEnabled
  }
  
  /// 指定されたノードがフォーカスされているかどうか
  public func isFocused(_ nodeId: ObjectIdentifier) -> Bool {
    return focusedNodeId == nodeId && isEnabled
  }
  
  /// 次のフォーカス可能なノードを取得
  public func nextFocusableNode() -> ObjectIdentifier? {
    guard isEnabled, !focusableNodes.isEmpty else { return nil }
    
    if let currentId = focusedNodeId,
       let currentIndex = focusableNodes.firstIndex(of: currentId) {
      let nextIndex = (currentIndex + 1) % focusableNodes.count
      return focusableNodes[nextIndex]
    }
    
    return focusableNodes.first
  }
  
  /// 前のフォーカス可能なノードを取得
  public func previousFocusableNode() -> ObjectIdentifier? {
    guard isEnabled, !focusableNodes.isEmpty else { return nil }
    
    if let currentId = focusedNodeId,
       let currentIndex = focusableNodes.firstIndex(of: currentId) {
      let previousIndex = currentIndex > 0 ? currentIndex - 1 : focusableNodes.count - 1
      return focusableNodes[previousIndex]
    }
    
    return focusableNodes.last
  }
}

// MARK: - Animation

/// アニメーション設定（将来の実装用）
public struct Animation {
  /// アニメーションの期間
  public let duration: TimeInterval
  
  /// イージング関数
  public let easing: Easing
  
  /// 遅延
  public let delay: TimeInterval
  
  /// イニシャライザ
  public init(
    duration: TimeInterval,
    easing: Easing = .linear,
    delay: TimeInterval = 0
  ) {
    self.duration = duration
    self.easing = easing
    self.delay = delay
  }
  
  /// デフォルトアニメーション
  public static var `default`: Animation {
    Animation(duration: 0.3, easing: .easeInOut)
  }
}

/// イージング関数
public enum Easing {
  case linear
  case easeIn
  case easeOut
  case easeInOut
  
  /// 進行度を計算
  public func value(at progress: Double) -> Double {
    switch self {
    case .linear:
      return progress
    case .easeIn:
      return progress * progress
    case .easeOut:
      return 1 - (1 - progress) * (1 - progress)
    case .easeInOut:
      return progress < 0.5
        ? 2 * progress * progress
        : 1 - pow(-2 * progress + 2, 2) / 2
    }
  }
}

// MARK: - Node Storage

/// ノードの状態を保持するストレージ
///
/// RenderNode間で共有される状態を管理します。
/// @Stateや@Bindingの値を保持するために使用されます。
public class NodeStorage {
  /// ストレージの実体
  private var storage: [ObjectIdentifier: Any] = [:]
  
  /// パブリックイニシャライザ
  public init() {}
  
  /// 値を取得
  public func getValue<T>(for key: ObjectIdentifier, default defaultValue: @autoclosure () -> T) -> T {
    if let value = storage[key] as? T {
      return value
    }
    let value = defaultValue()
    storage[key] = value
    return value
  }
  
  /// 値を設定
  public func setValue<T>(_ value: T, for key: ObjectIdentifier) {
    storage[key] = value
  }
  
  /// 値を削除
  public func removeValue(for key: ObjectIdentifier) {
    storage.removeValue(forKey: key)
  }
  
  /// すべての値をクリア
  public func clear() {
    storage.removeAll()
  }
}

// MARK: - Context Keys

/// 環境値のキー（拡張用）
public protocol RenderContextKey {
  associatedtype Value
  static var defaultValue: Value { get }
}

/// RenderContextの拡張（カスタム環境値用）
extension RenderContext {
  /// カスタム環境値を取得
  public func value<K: RenderContextKey>(for key: K.Type) -> K.Value {
    // 現在はEnvironmentValuesを使用
    // 将来的にはRenderContext独自の環境値システムを実装可能
    return K.defaultValue
  }
}