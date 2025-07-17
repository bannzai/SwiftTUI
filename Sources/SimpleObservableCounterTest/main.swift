import SwiftTUI

// 最もシンプルなObservableテスト
class Counter: Observable {
  var value = 0 {
    didSet {
      print("[DEBUG] Counter.value changed to: \(value)")
      notifyChange()
    }
  }
}

struct CounterView: View {
  @Environment(Counter.self) var counter: Counter?

  var body: some View {
    VStack {
      Text("Simple Observable Counter")
        .bold()
        .padding()

      // まず環境値が取得できているか確認
      if let counter = counter {
        Text("Counter found!")
          .foregroundColor(.green)
          .padding()

        // 直接値を表示
        Text("Direct value: 42")
          .padding()

        // 文字列補間をテスト
        Text("Value: \(counter.value)")
          .foregroundColor(.cyan)
          .padding()
          .border()

        // ボタンで値を変更
        HStack(spacing: 2) {
          Button("-") {
            counter.value -= 1
            print("[Button] Decrement pressed, new value: \(counter.value)")
          }
          Button("0") {
            counter.value = 0
            print("[Button] Reset pressed")
          }
          Button("+") {
            counter.value += 1
            print("[Button] Increment pressed, new value: \(counter.value)")
          }
        }
      } else {
        Text("Counter is nil!")
          .foregroundColor(.red)
          .padding()
          .border()
      }

      Text("Press q to quit")
        .foregroundColor(.white)
        .padding(.top)
    }
  }
}

// メイン
print("[DEBUG] Creating Counter instance...")
let counter = Counter()
print("[DEBUG] Initial counter.value: \(counter.value)")

// グローバルキーハンドラー
GlobalKeyHandler.handler = { event in
  switch event.key {
  case .character("q"):
    print("\n[DEBUG] Quitting...")
    CellRenderLoop.shutdown()
    return true
  case .character("+"):
    print("[Key] + pressed")
    counter.value += 1
    return true
  case .character("-"):
    print("[Key] - pressed")
    counter.value -= 1
    return true
  case .character("0"):
    print("[Key] 0 pressed")
    counter.value = 0
    return true
  default:
    return false
  }
}

print("[DEBUG] Starting SwiftTUI.run...")

SwiftTUI.run(
  CounterView()
    .environment(counter)
)
