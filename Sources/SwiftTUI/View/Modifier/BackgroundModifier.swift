//
//  BackgroundModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/18.
//

import Foundation

public protocol BackgroundColorModifier {
    // FIXME: Confirm to `View`
    // FIXME: Want interface of background<T: View>(_ background: T) -> _BackgroundModifier<T>
    func background(_ color: Color) -> Self
}
