import SwiftTUI
import Foundation

print("ViewModifier Test starting...")

struct TestView: View {
    var body: some View {
        VStack {
            Text("With padding and border")
                .padding(2)
                .border()
            
            Text("Red text")
                .foregroundColor(.red)
            
            Text("Blue background")
                .background(.blue)
            
            Text("Green text on yellow bg")
                .foregroundColor(.green)
                .background(.yellow)
                .padding()
        }
    }
}

// 短時間で終了
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    print("Exiting...")
    RenderLoop.shutdown()
    exit(0)
}

SwiftTUI.run(TestView())