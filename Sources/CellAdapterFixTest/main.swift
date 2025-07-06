import SwiftTUI

// CellLayoutAdapterの修正をテスト
struct CellAdapterFixTestView: View {
    var body: some View {
        HStack {
            Text("A").background(.red)
            Text("B").background(.green) 
            Text("C").background(.blue)
        }
    }
}

SwiftTUI.run {
    CellAdapterFixTestView()
}