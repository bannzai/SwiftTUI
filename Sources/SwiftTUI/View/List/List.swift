//
//  List.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/14.
//

import Foundation

public struct List<SelectionValue, Content>: View where SelectionValue: Swift.Hashable, Content: View {
    public init(selection: Binding<Swift.Set<SelectionValue>>?, @ViewBuilder content: () -> Content) { fatalError() }
    public init(selection: Binding<SelectionValue?>?, @ViewBuilder content: () -> Content) { fatalError() }
    public var body: some View {
        return fatalError()
    }
//    public typealias Body = @_opaqueReturnTypeOf("$s7SwiftUI4ListV4bodyQrvp", 0) 🦸<SelectionValue, Content>
}
extension List {
    public init<Data, RowContent>(_ data: Data, selection: Binding<Swift.Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>, Data: Swift.RandomAccessCollection, RowContent: View, Data.Element: Swift.Identifiable { fatalError() }
    public init<Data, ID, RowContent>(_ data: Data, id: Swift.KeyPath<Data.Element, ID>, selection: Binding<Swift.Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, ID, HStack<RowContent>>, Data: Swift.RandomAccessCollection, ID: Swift.Hashable, RowContent: View { fatalError() }
    public init<RowContent>(_ data: Swift.Range<Swift.Int>, selection: Binding<Swift.Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Swift.Int) -> RowContent) where Content == ForEach<Swift.Range<Swift.Int>, Swift.Int, HStack<RowContent>>, RowContent: View { fatalError() }
    public init<Data, RowContent>(_ data: Data, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>, Data: Swift.RandomAccessCollection, RowContent: View, Data.Element: Swift.Identifiable { fatalError() }
    public init<Data, ID, RowContent>(_ data: Data, id: Swift.KeyPath<Data.Element, ID>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, ID, HStack<RowContent>>, Data: Swift.RandomAccessCollection, ID: Swift.Hashable, RowContent: View { fatalError() }
    public init<RowContent>(_ data: Swift.Range<Swift.Int>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Swift.Int) -> RowContent) where Content == ForEach<Swift.Range<Swift.Int>, Swift.Int, HStack<RowContent>>, RowContent: View { fatalError() }
}

extension List: Primitive { }
