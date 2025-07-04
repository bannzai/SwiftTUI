@resultBuilder
public enum LegacyViewBuilder {
  public static func buildBlock(_ components: any LegacyView...) -> [LegacyAnyView] {
    components.map { LegacyAnyView($0) }
  }
}
