//
//  FrameModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/24.
//

import Foundation

@available(OSX 10.15.0, *)
extension View {
    public func frame(width: PhysicalDistance? = nil, height: PhysicalDistance? = nil) -> some View {
        self._baseProperty?.size?.width = width
        self._baseProperty?.size?.height = height
        return self
    }
    
    public func frame() -> some View {
        return frame(width: nil, height: nil)
    }
}

