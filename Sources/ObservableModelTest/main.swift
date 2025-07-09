import SwiftTUI

// シンプルなObservableBaseテスト
class CounterModel: ObservableBase {
    @Published var count = 0
    
    func increment() {
        count += 1
    }
    
    func decrement() {
        count -= 1
    }
    
    func reset() {
        count = 0
    }
}

struct SimpleObservableTest: View {
    @StateObject private var counter = CounterModel()
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Observable Test")
                .bold()
                .padding(.bottom)
            
            Text("Count: \(counter.count)")
                .foregroundColor(counter.count > 0 ? .green : .red)
                .padding()
                .border()
            
            HStack(spacing: 2) {
                Button("-") {
                    counter.decrement()
                }
                
                Button("Reset") {
                    counter.reset()
                }
                
                Button("+") {
                    counter.increment()
                }
            }
            .padding()
            
            Text("Press +/- to change count")
                .foregroundColor(.white)
        }
        .padding()
    }
}

SwiftTUI.run(SimpleObservableTest())
