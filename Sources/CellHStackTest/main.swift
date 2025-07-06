import SwiftTUI

// セルベースレンダリングを使用したHStackテスト
struct CellHStackTestView: View {
    var body: some View {
        VStack {
            Text("Cell-based HStack Test")
                .foregroundColor(.cyan)
                .bold()
            
            Text("")
            Text("1. Backgrounds in HStack (Fixed!):")
            
            // このHStackは内部でCellFlexStackを使用
            HStack {
                Text("AAA")
                    .background(.red)
                Text("BBB")
                    .background(.green)
                Text("CCC")
                    .background(.blue)
            }
            
            Text("")
            Text("2. Borders in HStack (Fixed!):")
            
            HStack {
                Text("X")
                    .border()
                Text("Y")
                    .border()
                Text("Z")
                    .border()
            }
            
            Text("")
            Text("3. Complex example:")
            
            HStack {
                Text("Hello")
                    .foregroundColor(.white)
                    .background(.red)
                    .border()
                
                Text("World")
                    .foregroundColor(.black)
                    .background(.yellow)
                    .border()
            }
        }
    }
}

// 通常のSwiftTUI実行（内部でセルベースレンダリングが使用される）
SwiftTUI.run {
    CellHStackTestView()
}