//
//  ViewGraphImpl.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import Foundation

public final class ViewGraphImpl<View: SwiftTUI.View>: ViewGraph {
    internal typealias ViewType = View
    
    internal var view: View
    internal init(view: View) {
        self.view = view
    }
    
    public var body: some SwiftTUI.View {
        view.body
    }
    
    override var anyView: Any {
        view
    }

    // MARK: - Override function
    override func update() {
        if #available(OSX 10.15.4, *) {
            _forEachField(of: ViewType.self) { (nameC: UnsafePointer<CChar>, offset: Int, childType: Any.Type, metadataKind: _MetadataKind) -> Bool in
                print("nameC: \(nameC), offset: \(offset), childType: \(childType), metadataKind: \(metadataKind)")
                withUnsafeMutablePointer(to: &view) { (pointer) in
                    UnsafeMutableRawPointer(pointer)
                        .advanced(by: offset)
                        .assumingMemoryBound(to: DynamicProperty.self)
                        .pointee
                }
//                withUnsafeMutablePointer(to: ) { pointer in
//                    UnsafeMutableRawPointer(pointer)
//                        .advanced(by: offset)
//                        .assumingMemoryBound(to: DynamicProperty.self)
//                        .pointee.update()
//                }
                return true
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
