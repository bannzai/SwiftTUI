//
//  List.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/14.
//

import Foundation

public struct List<SelectionValue, Content>: View where SelectionValue: Swift.Hashable, Content: View {
    internal var selection: Binding<SelectionValue?>?
    internal var selectionSet: Binding<Swift.Set<SelectionValue>>?
    internal var content: Content
    public init(selection: Binding<Swift.Set<SelectionValue>>?, @ViewBuilder content: () -> Content) {
        self.selectionSet = selection
        self.content = content()
    }
    public init(selection: Binding<SelectionValue?>?, @ViewBuilder content: () -> Content) {
        self.selection = selection
        self.content = content()
    }
    
    // NOTE: Actually SwiftUI interface
//    public typealias Body = @_opaqueReturnTypeOf("$s7SwiftUI4ListV4bodyQrvp", 0) 🦸<SelectionValue, Content>
}
extension List {
    public init<Data, RowContent>(_ data: Data, selection: Binding<Swift.Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>, Data: Swift.RandomAccessCollection, RowContent: View, Data.Element: Swift.Identifiable {
        self.selectionSet = selection
        self.content = ForEach.init(data) { element in
            HStack {
                rowContent(element)
            }
        }
    }
    public init<Data, ID, RowContent>(_ data: Data, id: Swift.KeyPath<Data.Element, ID>, selection: Binding<Swift.Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, ID, HStack<RowContent>>, Data: Swift.RandomAccessCollection, ID: Swift.Hashable, RowContent: View {
        self.selectionSet = selection
        self.content = ForEach.init(data, id: id, content: { element in
            HStack {
                rowContent(element)
            }
        })
    }
    public init<RowContent>(_ data: Swift.Range<Swift.Int>, selection: Binding<Swift.Set<SelectionValue>>?, @ViewBuilder rowContent: @escaping (Swift.Int) -> RowContent) where Content == ForEach<Swift.Range<Swift.Int>, Swift.Int, HStack<RowContent>>, RowContent: View {
        self.selectionSet = selection
        self.content = ForEach.init(data) { (element) in
            HStack {
                rowContent(element)
            }
        }
    }
    public init<Data, RowContent>(_ data: Data, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, Data.Element.ID, HStack<RowContent>>, Data: Swift.RandomAccessCollection, RowContent: View, Data.Element: Swift.Identifiable {
        self.selection = selection
        self.content = ForEach.init(data) { element in
            HStack {
                rowContent(element)
            }
        }
    }
    public init<Data, ID, RowContent>(_ data: Data, id: Swift.KeyPath<Data.Element, ID>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Content == ForEach<Data, ID, HStack<RowContent>>, Data: Swift.RandomAccessCollection, ID: Swift.Hashable, RowContent: View {
        self.selection = selection
        self.content = ForEach.init(data, id: id) { element in
            HStack {
                rowContent(element)
            }
        }
    }
    public init<RowContent>(_ data: Swift.Range<Swift.Int>, selection: Binding<SelectionValue?>?, @ViewBuilder rowContent: @escaping (Swift.Int) -> RowContent) where Content == ForEach<Swift.Range<Swift.Int>, Swift.Int, HStack<RowContent>>, RowContent: View {
        self.selection = selection
        self.content = ForEach.init(data) { element in
            HStack {
                rowContent(element)
            }
        }
    }
}

extension List: Primitive { }
