/// Paddingを適用するView
public struct PaddingModifier: ViewModifier {
    let edges: Edge.Set
    let length: Int?
    
    public init(_ edges: Edge.Set = .all, _ length: Int? = nil) {
        self.edges = edges
        self.length = length
    }
    
    public func body(content: Content) -> some View {
        // 一時的にコンテンツをそのまま返す
        // TODO: 実際のpadding実装
        content
    }
}

/// エッジの定義
public enum Edge {
    case top
    case leading
    case bottom
    case trailing
    
    public struct Set: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let top = Set(rawValue: 1 << 0)
        public static let leading = Set(rawValue: 1 << 1)
        public static let bottom = Set(rawValue: 1 << 2)
        public static let trailing = Set(rawValue: 1 << 3)
        
        public static let all: Set = [.top, .leading, .bottom, .trailing]
        public static let horizontal: Set = [.leading, .trailing]
        public static let vertical: Set = [.top, .bottom]
    }
}

// View拡張：padding modifier
public extension View {
    /// 全方向にpadding
    func padding(_ length: Int = 1) -> some View {
        modifier(PaddingModifier(.all, length))
    }
    
    /// 指定した方向にpadding
    func padding(_ edges: Edge.Set, _ length: Int = 1) -> some View {
        modifier(PaddingModifier(edges, length))
    }
    
    /// 特定のエッジにpadding
    func padding(_ edge: Edge.Set) -> some View {
        modifier(PaddingModifier(edge, 1))
    }
}

// Edge拡張
public extension Edge {
    var toSet: Edge.Set {
        switch self {
        case .top: return .top
        case .leading: return .leading
        case .bottom: return .bottom
        case .trailing: return .trailing
        }
    }
}

// Edgeを直接受け取るバージョン
public extension View {
    func padding(_ edge: Edge, _ length: Int = 1) -> some View {
        modifier(PaddingModifier(edge.toSet, length))
    }
}