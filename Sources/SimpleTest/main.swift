import SwiftTUI

// 直接LegacyTextを使用
print("SimpleTest: Starting...")
RenderLoop.mount {
    LegacyText("Hello from Legacy!")
}
dispatchMain()