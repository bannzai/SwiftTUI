//
//  ViewPropetySettingVisitor.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/27.
//

import Foundation

open class ViewPropetySettingVisitor: Visitor {
    public typealias VisitResult = Void
    open func visit<T: View>(_ content: T) -> ViewPropetySettingVisitor.VisitResult {
        fatalError("Should override this method to subclass")
    }
}


public final class SizePropertySettingVisitor: ViewPropetySettingVisitor {
    public override func visit<T: View>(_ content: T) {
        content._baseProperty?.size?.width
    }
}
