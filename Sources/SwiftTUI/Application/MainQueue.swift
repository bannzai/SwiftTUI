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
    
    internal weak var drawable: Drawable?
    
    func message(with event: Event) {
        DispatchQueue.main.async { [weak self] in
            event.closure()
            self?.drawable?.draw()
        }
    }
}
