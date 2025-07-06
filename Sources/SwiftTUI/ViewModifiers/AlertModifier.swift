import Foundation

/// Alert表示用のModifier
public struct AlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String?
    let buttons: [AlertButton]
    
    public init(isPresented: Binding<Bool>, title: String, message: String? = nil, buttons: [AlertButton]) {
        self._isPresented = isPresented
        self.title = title
        self.message = message
        self.buttons = buttons
    }
    
    public func body(content: Content) -> some View {
        // 現在の実装では、Alertをオーバーレイとして表示するのは複雑なため、
        // 条件付きでAlertViewを表示する
        if isPresented {
            AlertView(
                title: title,
                message: message,
                buttons: buttons,
                isPresented: _isPresented
            )
        } else {
            content
        }
    }
}

/// Alertのボタン定義
public struct AlertButton {
    let title: String
    let role: ButtonRole?
    let action: () -> Void
    
    public enum ButtonRole {
        case cancel
        case destructive
    }
    
    public init(_ title: String, role: ButtonRole? = nil, action: @escaping () -> Void = {}) {
        self.title = title
        self.role = role
        self.action = action
    }
    
    public static func cancel(_ title: String = "Cancel", action: @escaping () -> Void = {}) -> AlertButton {
        AlertButton(title, role: .cancel, action: action)
    }
    
    public static func destructive(_ title: String, action: @escaping () -> Void) -> AlertButton {
        AlertButton(title, role: .destructive, action: action)
    }
}

/// Alert表示用のView
public struct AlertView: View {
    let title: String
    let message: String?
    let buttons: [AlertButton]
    @Binding var isPresented: Bool
    @State private var selectedButtonIndex = 0
    
    public var body: some View {
        VStack(spacing: 2) {
            // 背景を暗くするための領域（簡易実装）
            Text(String(repeating: " ", count: 60))
                .background(Color.black)
                .padding()
            
            VStack(spacing: 1) {
                // タイトル
                Text(title)
                    .bold()
                    .padding()
                
                // メッセージ
                if let message = message {
                    Text(message)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                
                // ボタン
                HStack(spacing: 2) {
                    // ForEachを使わずに直接ボタンを配置
                    if buttons.count > 0 {
                        AlertButtonView(
                            button: buttons[0],
                            isSelected: selectedButtonIndex == 0,
                            action: {
                                buttons[0].action()
                                isPresented = false
                            }
                        )
                    }
                    if buttons.count > 1 {
                        AlertButtonView(
                            button: buttons[1],
                            isSelected: selectedButtonIndex == 1,
                            action: {
                                buttons[1].action()
                                isPresented = false
                            }
                        )
                    }
                }
                .padding()
            }
            .border()
            .background(Color.white)
            
            Text(String(repeating: " ", count: 60))
                .background(Color.black)
                .padding()
        }
    }
}

/// Alertのボタン表示用View
struct AlertButtonView: View {
    let button: AlertButton
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(button.title, action: action)
            .foregroundColor(buttonColor)
            .background(isSelected ? Color.blue : Color.clear)
    }
    
    private var buttonColor: Color {
        switch button.role {
        case .cancel:
            return .blue
        case .destructive:
            return .red
        case nil:
            return .white
        }
    }
}

// View拡張でalertモディファイアを追加
public extension View {
    func alert(_ title: String, isPresented: Binding<Bool>, actions: () -> [AlertButton], message: () -> String? = { nil }) -> some View {
        self.modifier(AlertModifier(
            isPresented: isPresented,
            title: title,
            message: message(),
            buttons: actions()
        ))
    }
}