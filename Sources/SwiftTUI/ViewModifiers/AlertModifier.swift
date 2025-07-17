import Foundation

/// Alert表示用のModifier
public struct AlertModifier: ViewModifier {
  @Binding var isPresented: Bool
  let title: String
  let message: String?

  public init(isPresented: Binding<Bool>, title: String, message: String? = nil) {
    self._isPresented = isPresented
    self.title = title
    self.message = message
  }

  public func body(content: Content) -> some View {
    // ViewRendererでAlertModifierLayoutViewに変換される
    // ここではContentをそのまま返す（実際の処理はLayoutViewで行う）
    content
  }
}

// View拡張でalertモディファイアを追加
extension View {
  /// Alertを表示するモディファイア
  /// - Parameters:
  ///   - title: アラートのタイトル
  ///   - isPresented: アラート表示フラグのBinding
  ///   - message: オプショナルなメッセージ
  public func alert(_ title: String, isPresented: Binding<Bool>, message: String? = nil)
    -> some View
  {
    self.modifier(AlertModifier(isPresented: isPresented, title: title, message: message))
  }
}

/// AlertModifier用のLayoutView
internal class AlertModifierLayoutView: LayoutView {
  let contentLayoutView: any LayoutView
  let isPresented: Binding<Bool>
  let title: String
  let message: String?

  init(content: any LayoutView, isPresented: Binding<Bool>, title: String, message: String?) {
    self.contentLayoutView = content
    self.isPresented = isPresented
    self.title = title
    self.message = message
  }

  func makeNode() -> YogaNode {
    // アラート表示中はアラートのノードを返す
    if isPresented.wrappedValue {
      let alert = Alert(
        title: title, message: message,
        dismiss: { [weak self] in
          self?.isPresented.wrappedValue = false
        })
      return alert._layoutView.makeNode()
    } else {
      // 通常時はコンテンツのノードを返す
      return contentLayoutView.makeNode()
    }
  }

  func paint(origin: (x: Int, y: Int), into buffer: inout [String]) {
    if isPresented.wrappedValue {
      // アラート表示中はアラートを描画
      let alert = Alert(
        title: title, message: message,
        dismiss: { [weak self] in
          self?.isPresented.wrappedValue = false
        })
      alert._layoutView.paint(origin: origin, into: &buffer)
    } else {
      // 通常時はコンテンツを描画
      contentLayoutView.paint(origin: origin, into: &buffer)
    }
  }

  func render(into buffer: inout [String]) {
    if isPresented.wrappedValue {
      let alert = Alert(
        title: title, message: message,
        dismiss: { [weak self] in
          self?.isPresented.wrappedValue = false
        })
      alert._layoutView.render(into: &buffer)
    } else {
      contentLayoutView.render(into: &buffer)
    }
  }
}

// CellLayoutView対応
extension AlertModifierLayoutView: CellLayoutView {
  func paintCells(origin: (x: Int, y: Int), into buffer: inout CellBuffer) {
    if isPresented.wrappedValue {
      // アラート表示中
      let alert = Alert(
        title: title, message: message,
        dismiss: { [weak self] in
          self?.isPresented.wrappedValue = false
        })
      if let cellLayoutView = alert._layoutView as? CellLayoutView {
        cellLayoutView.paintCells(origin: origin, into: &buffer)
      }
    } else {
      // 通常時
      if let cellLayoutView = contentLayoutView as? CellLayoutView {
        cellLayoutView.paintCells(origin: origin, into: &buffer)
      }
    }
  }
}
