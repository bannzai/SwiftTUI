/// SwiftUIライクなForEach View
public struct ForEach<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    internal let data: Data
    internal let id: KeyPath<Data.Element, ID>
    internal let content: (Data.Element) -> Content
    
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.id = id
        self.content = content
    }
    
    public var body: some View {
        // ForEachの内容を展開してGroupとして返す
        Group {
            _ForEachContent(data: data, id: id, content: content)
        }
    }
}

// Identifiableプロトコルに準拠する場合の簡易版
public extension ForEach where ID == Data.Element.ID, Data.Element: Identifiable {
    init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.init(data, id: \.id, content: content)
    }
}

// Rangeを使用する場合の特殊化
public struct ForEachRange<Content: View>: View {
    internal let range: Range<Int>
    internal let content: (Int) -> Content
    
    public init(_ range: Range<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.range = range
        self.content = content
    }
    
    public var body: some View {
        Group {
            _ForEachRangeContent(range: range, content: content)
        }
    }
}


// 内部実装用のヘルパーView
private struct _ForEachContent<Data: RandomAccessCollection, ID: Hashable, Content: View>: View {
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let content: (Data.Element) -> Content
    
    var body: some View {
        // データを展開してTupleViewとして返す
        if data.isEmpty {
            EmptyView()
        } else {
            // 各要素のViewを生成してGroupに包む
            Group {
                ForEachExpanded(views: data.map { content($0) })
            }
        }
    }
}

private struct _ForEachRangeContent<Content: View>: View {
    let range: Range<Int>
    let content: (Int) -> Content
    
    var body: some View {
        if range.isEmpty {
            EmptyView()
        } else {
            Group {
                ForEachExpanded(views: range.map { content($0) })
            }
        }
    }
}

// 展開されたViewの集合を表す内部View
private struct ForEachExpanded<Content: View>: View {
    let views: [Content]
    
    var body: some View {
        // 単純にEmptyViewを返す（実際のレンダリングはViewRendererで処理）
        EmptyView()
    }
}

// ViewRendererでForEachExpandedを特別扱いするためのプロトコル
internal protocol _ForEachExpandedProtocol {
    var _views: [any View] { get }
}

extension ForEachExpanded: _ForEachExpandedProtocol {
    var _views: [any View] {
        views.map { $0 as any View }
    }
}