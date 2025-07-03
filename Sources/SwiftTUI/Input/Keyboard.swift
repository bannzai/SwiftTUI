public enum KeyboardKey: Equatable {
  case character(Character)
  case enter
  case escape
  case arrowUp, arrowDown, arrowLeft, arrowRight
  case unknown
}

public struct KeyboardEvent {
  public let key: KeyboardKey
}
