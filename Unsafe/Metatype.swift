//
//  Metatype.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/17.
//

import Foundation

// Reference: https://gist.github.com/kateinoigakukun/89cc89048fc9fa6c86c26bb4230617b9
struct StructTypeMetadata {
    let kind: UInt
    var typeDescriptor: UnsafeMutablePointer<StructTypeDescriptor>
}

struct StructTypeDescriptor {
    let flags: Int32
    let parentContextDescriptor: Int32
    var name: RelativePointer<CChar>
}

struct RelativePointer<Pointee> {
    var offset: Int32

    mutating func advanced() -> UnsafeMutablePointer<Pointee> {
        return withUnsafePointer(to: &self) { [offset] pointer in
            let rawPointer = UnsafeRawPointer(pointer)
            let advanced = rawPointer.advanced(by: Int(offset))
            let pointer = advanced.assumingMemoryBound(to: Pointee.self)
            return UnsafeMutablePointer(mutating: pointer)
        }
    }
}
