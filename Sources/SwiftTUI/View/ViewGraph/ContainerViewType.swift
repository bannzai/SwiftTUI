//
//  ContainerViewType.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/03/28.
//

import Foundation

/// ContainerViewType is annotation for that can contain child views
internal protocol ContainerViewType {
    
}

extension VStack: ContainerViewType { }
extension HStack: ContainerViewType { }
