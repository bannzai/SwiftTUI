public enum KeyboardKey: Equatable {
  case character(Character)    // a–z
  case char(Character)         // alias for backward compatibility
  case escape
  case enter
  case space
  case tab
  case backspace
  case delete
  case up
  case down
  case left
  case right
  case home
  case end
}

public struct KeyboardEvent {
  public let key: KeyboardKey
}
