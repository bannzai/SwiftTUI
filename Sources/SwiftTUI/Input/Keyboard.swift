public enum KeyboardKey: Equatable {
  case character(Character)    // a–z
  case escape
}

public struct KeyboardEvent {
  public let key: KeyboardKey
}
