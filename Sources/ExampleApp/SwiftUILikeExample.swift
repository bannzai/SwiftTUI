import SwiftTUI

// SwiftUIライクなAPIを使用したサンプル
struct SwiftUILikeExampleApp: View {
  var body: some View {
    VStack(spacing: 1) {
      Text("Hello, SwiftTUI!")
        .foregroundColor(.cyan)
        .bold()
        .padding()
        .border()

      HStack {
        Text("Left")
          .foregroundColor(.green)

        Text("Right")
          .foregroundColor(.red)
      }
      .padding()

      Text("Bottom Text")
        .background(.blue)
        .padding()
    }
  }
}

// エントリーポイント
@main
struct SwiftUILikeExample {
  static func main() {
    SwiftTUI.run(SwiftUILikeExampleApp())
  }
}
