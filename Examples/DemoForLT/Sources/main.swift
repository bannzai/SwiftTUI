import Darwin
import SwiftTUI

// デモ1: Hello World
struct HelloWorldDemo: View {
  var body: some View {
    Text("Hello, SwiftTUI! 🚀")
      .foregroundColor(.cyan)
      .bold()
      .padding()
      .border()
  }
}

// デモ2: インタラクティブフォーム
struct FormDemo: View {
  @State private var name = ""
  @State private var email = ""

  var body: some View {
    VStack(spacing: 1) {
      Text("ユーザー登録")
        .bold()
        .padding(.bottom)

      HStack(alignment: .top) {
        Text("名前:")
        TextField("お名前", text: $name)
          .frame(width: 20)
          .border()
      }

      HStack(alignment: .top) {
        Text("Email:")
        TextField("email@example.com", text: $email)
          .frame(width: 25)
          .border()
      }

      Button("送信") {
        print("登録: \(name) (\(email))")
      }
      .padding(.top)
    }
    .padding()
    .border()
  }
}

// デモ3: リスト表示
struct ListDemo: View {
  let items = ["Swift", "SwiftUI", "SwiftTUI", "Terminal", "TUI"]

  var body: some View {
    VStack {
      Text("技術スタック")
        .bold()
        .padding(.bottom)

      List {
        ForEach(items, id: \.self) { item in
          Text("• \(item)")
        }
      }
      .frame(height: 10)
    }
    .padding()
    .border()
  }
}

// デモ選択
struct DemoSelector: View {
  @State private var selectedDemo = 1

  var body: some View {
    VStack {
      HStack {
        Button("Hello") { selectedDemo = 1 }
        Button("Form") { selectedDemo = 2 }
        Button("List") { selectedDemo = 3 }
        Button("Quit") { exit(0) }
      }
      .padding(.bottom)

      switch selectedDemo {
      case 1:
        HelloWorldDemo()
      case 2:
        FormDemo()
      case 3:
        ListDemo()
      default:
        Text("Select a demo")
      }
    }
  }
}

SwiftTUI.run(DemoSelector())
