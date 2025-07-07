// RealCellDebugTest - 実際のSwiftTUIビューでセルレンダリングをデバッグ
//
// Expected behavior:
// - 単一のText要素に赤背景色を適用して正常にレンダリング
// - HStack内の複数Text要素に異なる背景色（赤、緑、青）を適用
// - CellRenderLoopのデバッグ情報を表示
//
// Note: SwiftTUIのビューシステムでのセルベースレンダリング統合テスト
//
// How to run: swift run RealCellDebugTest

import SwiftTUI
import Foundation

// 実際のSwiftTUIビューでのデバッグ
struct RealCellDebugView: View {
    var body: some View {
        VStack {
            Text("Single text with background:")
            Text("RED").background(.red)
            
            Text("\nHStack with backgrounds:")
            HStack {
                Text("A").background(.red)
                Text("B").background(.green) 
                Text("C").background(.blue)
            }
        }
    }
}

// デバッグモードを有効化
CellRenderLoop.DEBUG = true

SwiftTUI.run {
    RealCellDebugView()
}