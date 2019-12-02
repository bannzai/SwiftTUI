//
//  Application.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/07.
//

import Foundation

// Application is management SwiftTUI process with root view
public class Application<Root: View> {

    let viewController: HostViewController<Root>
    public init(viewController: HostViewController<Root>) {
        self.viewController = viewController
    }
    
    public func run() {
        viewController.draw()
        RunLoop.main.run()
    }
}

extension View {
    
}
