//
//  Application.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/07.
//

import Foundation

// Application is management SwiftTUI process with root view
public class Application<RootView: View> {
    let view: RootView
    
    public init(view: RootView) {
        self.view = view
    }
    
    public func run() {
        
    }
}

extension View {
    
}
