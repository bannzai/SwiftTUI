//
//  TestHelper.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/11.
//

import Foundation
@testable import SwiftTUI


struct BooleanStatableViewHasBindableView: View {
    @State var state: Bool
    var body: some View {
        BooleanBindableView(binding: $state)
    }
}

struct BooleanStatableView: View {
    @State var state: Bool
    var body: some View {
        VStack {
            if state {
                Text("true")
            } else {
                Text("false")
            }
        }
    }
}

struct BooleanBindableView: View {
    @Binding var binding: Bool
    var body: some View {
        VStack {
            if binding {
                Text("true")
            } else {
                Text("false")
            }
        }
    }
}
