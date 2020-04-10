//
//  ViewGraphImpl.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import Foundation

public final class ViewGraphImpl<View: SwiftTUI.View>: ViewGraph {
    internal typealias ViewType = View
    
    internal let view: View
    internal init(view: View) {
        self.view = view
    }
    
    public var body: some SwiftTUI.View {
        view.body
    }
    
    override var anyView: Any {
        view
    }
}

// MARK: - For Dynamic Property
internal extension ViewGraphImpl {
    func eachDynamicProperty() -> [DynamicProperty] {
        Mirror(reflecting: view)
            .children
            .compactMap { $0.value as? DynamicProperty }
    }
    
    func callDynamicPropertyUpdate() {
        eachDynamicProperty().forEach {
            $0.update()
        }
    }
}