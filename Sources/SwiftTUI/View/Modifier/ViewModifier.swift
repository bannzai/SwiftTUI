//
//  ViewModifier.swift
//  SwiftTUI
//
//  Created by Yudai.Hirose on 2019/11/18.
//

import Foundation

public struct _ViewModifier_Content<Modifier> where Modifier: ViewModifier {
  public typealias Body = Swift.Never
}

extension _ViewModifier_Content: View { }

public protocol ViewModifier {
  associatedtype Body : View
  func body(content: Self.Content) -> Self.Body
  typealias Content = _ViewModifier_Content<Self>
}
