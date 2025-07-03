@resultBuilder
public enum ViewBuilder {
  public static func buildBlock(_ components: View...) -> [AnyView] {
    components.map { AnyView($0) }
  }
}
