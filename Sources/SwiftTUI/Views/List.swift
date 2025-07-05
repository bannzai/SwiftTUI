/// SwiftUIライクなList View
public struct List<Content: View>: View {
    internal let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    // List自体はプリミティブViewなのでbodyは持たない
    public typealias Body = Never
}

// データコレクションを使用するList
public struct ListWithData<Data: RandomAccessCollection, ID: Hashable, RowContent: View>: View {
    internal let data: Data
    internal let id: KeyPath<Data.Element, ID>
    internal let rowContent: (Data.Element) -> RowContent
    
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) {
        self.data = data
        self.id = id
        self.rowContent = rowContent
    }
    
    public var body: some View {
        List {
            ForEach(data, id: id) { item in
                rowContent(item)
            }
        }
    }
}


// 内部実装：ListLayoutViewへの変換
extension List {
    internal var _layoutView: any LayoutView {
        // contentをLayoutViewに変換
        let contentLayoutView = ViewRenderer.renderView(content)
        
        // ListLayoutViewとして返す
        return ListLayoutView(child: contentLayoutView)
    }
}