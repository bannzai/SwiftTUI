import SwiftTUI
import Foundation

// シンプルなテストケース
struct SimpleTest: View {
  var body: some View {
    VStack(spacing: 2) {
      // padding無しのケース
      Text("おしまい \(^o^)/")
        .border()
      
      // paddingありのケース（オリジナルと同じ）
      Text("おしまい \(^o^)/")
        .padding(2)
        .border()
      
      // 比較のために英語のみ
      Text("Hello World!")
        .border()
      
      // 日本語のみ
      Text("こんにちは")
        .border()
    }
  }
}

fputs("Starting CellBorderDebugTest...\n", stderr)

SwiftTUI.run(SimpleTest()) { event in
  switch event.key {
  case .character("q"):
    fputs("Exiting...\n", stderr)
    return false
  default:
    return true
  }
}