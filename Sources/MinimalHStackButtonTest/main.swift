import SwiftTUI

// デバッグフラグをオンにする
CellRenderLoop.DEBUG = true

struct MinimalHStackButtonTest: View {
    var body: some View {
        VStack {
            Text("HStack Button Test")
            
            HStack {
                Text("[")
                Button("Click") {
                    print("Clicked")
                }
                Text("]")
            }
        }
        .padding()
    }
}

SwiftTUI.run(MinimalHStackButtonTest())
