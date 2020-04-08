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
