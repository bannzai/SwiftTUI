//
//  AnyViewWrappable.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/08.
//

import Foundation

// AnyViewWrappable type erasure view
public protocol AnyViewWrappable {
    func wrappedAnyView() -> AnyView
}

