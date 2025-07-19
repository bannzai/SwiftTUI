import SwiftTUI

struct TextFieldJapaneseTest: View {
  @State private var name = "名前"
  @State private var email = ""
  @State private var mixed = "Hello 世界"
  
  var body: some View {
    VStack(spacing: 2) {
      Text("日本語文字表示テスト")
        .bold()
        .padding(.bottom, 1)
      
      // 上揃えのHStackでTextFieldを配置
      HStack(alignment: .top) {
        Text("名前:")
        TextField("お名前を入力", text: $name)
          .frame(width: 20)
          .border()
      }
      .padding()
      
      HStack(alignment: .top) {
        Text("メール:")
        TextField("example@mail.com", text: $email)
          .frame(width: 30)
          .border()
      }
      .padding()
      
      HStack(alignment: .top) {
        Text("混在:")
        TextField("Hello 世界", text: $mixed)
          .frame(width: 25)
          .border()
      }
      .padding()
      
      Text("入力内容:")
        .padding(.top, 1)
      Text("名前: \(name)")
      Text("メール: \(email)")
      Text("混在: \(mixed)")
      
      Button("終了 (q)") {
        exit(0)
      }
      .padding(.top, 2)
    }
    .padding()
    .border()
  }
}

SwiftTUI.run(TextFieldJapaneseTest()) { event in
  switch event.key {
  case .character("q"):
    return false
  default:
    return true
  }
}