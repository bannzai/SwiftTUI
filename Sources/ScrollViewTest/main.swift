import SwiftTUI

struct ScrollViewTestView: View {
    var body: some View {
        VStack {
            Text("ScrollView Test")
                .bold()
                .padding()
                .border()
            
            Text("Use arrow keys to scroll")
                .foregroundColor(.cyan)
                .padding()
            
            // Vertical ScrollView
            Text("Vertical ScrollView:")
                .padding(.top)
            
            ScrollView {
                VStack {
                    ForEach(1..<20) { i in
                        HStack {
                            Text("Row \(i)")
                                .foregroundColor(.green)
                            Spacer()
                            Text("Item \(i)")
                                .foregroundColor(.yellow)
                        }
                        .padding()
                        .background(i % 2 == 0 ? .blue : .magenta)
                    }
                }
            }
            .frame(height: 10)
            .border()
            .padding()
            
            // Horizontal ScrollView
            Text("Horizontal ScrollView:")
                .padding(.top)
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(1..<15) { i in
                        VStack {
                            Text("Col")
                            Text("\(i)")
                        }
                        .padding()
                        .background(i % 2 == 0 ? .red : .cyan)
                        .border()
                    }
                }
            }
            .frame(height: 5)
            .border()
            .padding()
        }
    }
}

SwiftTUI.run {
    ScrollViewTestView()
}