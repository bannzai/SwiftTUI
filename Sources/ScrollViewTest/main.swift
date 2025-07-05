import SwiftTUI

struct ScrollViewTestView: View {
    var body: some View {
        VStack {
            VStack {
                Text("ScrollView Test")
                    .bold()
                    .padding()
                    .border()
                
                Text("Use arrow keys to scroll")
                    .foregroundColor(.cyan)
                    .padding()
            }
            
            VStack {
                Text("Vertical ScrollView:")
                    .padding(.top)
                
                ScrollView {
                    VStack {
                        ForEachRange(1..<20) { i in
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
            }
            
            VStack {
                Text("Horizontal ScrollView:")
                    .padding(.top)
                
                ScrollView {
                    HStack {
                        ForEachRange(1..<15) { i in
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
}

SwiftTUI.run {
    ScrollViewTestView()
}