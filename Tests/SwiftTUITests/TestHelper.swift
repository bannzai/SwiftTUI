//
//  TestHelper.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation
@testable import SwiftTUI


@available(OSX 10.15.0, *)
extension _AcceptableType {
    struct DummyView: View {
        typealias Body = Never
        func _typeOf() -> _AcceptableType {
            fatalError()
        }
    }
    struct DummyModifier: ViewModifier {
        typealias Body = Never
    }
    struct Dummy_VariadicView_Root: _VariadicView_Root {
        
    }
    func acceptables() -> Acceptable {
        switch self {
        case .never: fatalError()
        case .any: return AnyView(DummyView())
        case .anyStorageBase: return AnyViewStorageBase()
        case .group: return Group { DummyView() }
        case .color: return Color.red
        case .empty: return EmptyView()
        case .font: return Font()
        case .text: return Text("")
        case .tuple: return TupleView(DummyView())
            
        case .modifier: return ModifiedContent(content: DummyView(), modifier: DummyModifier())
        case ._viewModifier_content: return _ViewModifier_Content<DummyModifier>()
        case .conditionalContent: return ViewBuilder._ConditionalContent<DummyView, DummyView>(storage: .truthy(DummyView()))
        case .variadicViewTree: return VariadicView.Tree(root: Dummy_VariadicView_Root(), content: DummyView())
            
        case .hStack: return HStack { DummyView() }
        case .vStack: return VStack { DummyView() }
        }
    }
}
