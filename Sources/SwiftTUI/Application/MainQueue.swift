//
//  MainQueue.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/12/03.
//

import Foundation

internal class MainQueue {
    internal struct Event {
        internal let closure: () -> Void
    }
    
    private weak var drawable: Drawable?
    internal func inject(drawable: Drawable) {
        self.drawable = drawable
    }
    
    func message(with event: Event) {
        DispatchQueue.main.async { [weak self] in
            event.closure()
            self?.drawable?.draw()
        }
    }
}
