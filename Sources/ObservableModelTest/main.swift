import SwiftTUI

// Observable実装のテスト（WWDC23スタイル）
class CounterModel: Observable {
  var count = 0 {
    didSet { notifyChange() }
  }

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

struct CounterView: View {
  @Environment(CounterModel.self) var counter: CounterModel?

  var body: some View {
    if let counter = counter {
      VStack(spacing: 2) {
        Text("Observable + Environment Test")
          .bold()
          .padding(.bottom)

        Text("Count: \(counter.count)")
          .foregroundColor(counter.count > 0 ? .green : .red)
          .border()
          .padding()

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
    } else {
      Text("No counter model in environment")
        .foregroundColor(.red)
    }
  }
}

// Observableインスタンスを作成してEnvironmentで渡す
let counter = CounterModel()

// デバッグモードを無効化
CellRenderLoop.DEBUG = false

// グローバルキーハンドラーでqキーで終了できるようにする
GlobalKeyHandler.handler = { event in
  switch event.key {
  case .character("q"):
    print("\nExiting...")
    CellRenderLoop.shutdown()
    return true
  default:
    return false
  }
}

SwiftTUI.run(
  CounterView()
    .environment(counter)
)
