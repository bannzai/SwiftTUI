//
//  ViewGraphMarker.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2020/04/08.
//

import Foundation

internal class ViewGraphMarker {
    private var markers: [ViewGraph: Void] = [:]
    func mark(graph: ViewGraph) {
        markers[graph] = ()
    }
    func isMarked(graph: ViewGraph) -> Bool {
        markers[graph] != nil
    }
    func reset() {
        markers = [:]
    }
}

internal let renderMarker = ViewGraphMarker()
internal let positionMarker = ViewGraphMarker()
internal let proposedSizeMarker = ViewGraphMarker()
