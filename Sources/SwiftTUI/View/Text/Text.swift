//
//  Text.swift
//  Demo
//
//  Created by Yudai.Hirose on 2019/11/06.
//

import Foundation

public final class _TextBaseProperty {
    internal var foregroundColor: Color? = nil
}

/// A view that displays one or more lines of read-only text.
public struct Text {
    let content: String
    internal var _textProperty: _TextBaseProperty = .init()
    /// Creates an instance that displays `content` verbatim.
    @inlinable public init(verbatim content: String) {
        self.init(content)
    }
    
    /// Creates an instance that displays `content` verbatim.
    public init<S>(_ content: S) where S : StringProtocol {
        self.content = String(content)
    }

}

extension Text: Primitive { }
extension Text: Rendable { }
extension Text: ViewGraphSetAcceptable {
    internal func accept(visitor: ViewGraphSetVisitor) -> ViewGraph {
        _accept(visitor: visitor)
    }
}
extension Text: Equatable {
    public static func == (lhs: Text, rhs: Text) -> Bool {
        return lhs.content == rhs.content
    }
}

extension Text {
    public static func + (lhs: Text, rhs: Text) -> Text {
        return Text(lhs.content + rhs.content)
    }
}

extension Text: View {
    public typealias Body = Never
}

extension Text: ViewContentAcceptable {
    internal func accept(visitor: ViewContentVisitor) -> ViewContentVisitor.VisitResult {
        debugLogger.debug()
        guard let graph = visitor.current, graph.anyView is Text else {
            fatalError("visitor.current should set ViewGraph \(String(describing: visitor.current))")
        }
        _textProperty.foregroundColor.map(visitor.driver.setForegroundColor)
        defer { visitor.driver.restoreForegroundColor() }
        content.components(separatedBy: "\n").enumerated().forEach { (offset, content) in
            if offset + 1 > graph.rect.size.height {
                return
            }
            let substring = content[content.startIndex..<content.index(content.startIndex, offsetBy: graph.rect.size.width)]
            visitor.driver.add(string: String(substring))
        }
    }
}

extension Text: ViewSetContentSizeVisitorAcceptable {
    func accept(visitor: ViewSetContentSizeVisitor) {
        let contents = content.split(separator: "\n").map { String($0) }
        guard let maxWidthString = contents.max (by: { $0.width < $1.width }) else {
            visitor.current?.contentSize = .zero
            return
        }
        visitor.current?.contentSize = Size(width: maxWidthString.width, height: contents.count)
    }
}
extension Text: ViewSetSizeVisitorAcceptable {
    func accept(visitor: ViewSetSizeVisitor) {
        let graph = visitor.current!
        graph.rect.size = graph.contentSize
    }
}

// TODO: Implement
// Mark: - Text interfaces
extension Text {
    /// Sets the color of this text.
    ///
    /// - Parameter color: The color to use when displaying this text.
    /// - Returns: Text that uses the color value you supply.
    public func foregroundColor(_ color: Color) -> Text {
        _textProperty.foregroundColor = color
        return self
    }

    /// Sets the font to use when displaying this text.
    ///
    /// - Parameter font: The font to use when displaying this text.
    /// - Returns: Text that uses the font you specify.
    public func font(_ font: Font?) -> Text {
        return self
    }

    /// Sets the font weight of this text.
    ///
    /// - Parameter weight: One of the available font weights.
    /// - Returns: Text that uses the font weight you specify.
    public func fontWeight(_ weight: Font.Weight?) -> Text {
        return self
    }

    /// Applies a bold font weight to this text.
    ///
    /// - Returns: Bold text.
    public func bold() -> Text {
        return self
    }

    /// Applies italics to this text.
    ///
    /// - Returns: Italic text.
    public func italic() -> Text {
        return self
    }

    /// Applies a strikethrough to this text.
    ///
    /// - Parameters:
    ///   - active: A Boolean value that indicates whether the text has a
    ///     strikethrough applied.
    ///   - color: The color of the strikethrough. If `color` is `nil`, the
    ///     strikethrough uses the default foreground color.
    /// - Returns: Text with a line through its center.
    public func strikethrough(_ active: Bool = true, color: Color? = nil) -> Text {
        return self
    }

    /// Applies an underline to this text.
    ///
    /// - Parameters:
    ///   - active: A Boolean value that indicates whether the text has an
    ///     underline.
    ///   - color: The color of the underline. If `color` is `nil`, the
    ///     underline uses the default foreground color.
    /// - Returns: Text with a line running along its baseline.
    public func underline(_ active: Bool = true, color: Color? = nil) -> Text {
        return self
    }

    /// Sets the kerning for this text.
    ///
    /// - Parameter kerning: How many points the following character should be
    ///   shifted from its default offset as defined by the current character's
    ///   font in points; a positive kerning indicates a shift farther along
    ///   and a negative kern indicates a shift closer to the current character.
    /// - Returns: Text with the specified amount of kerning.
    public func kerning(_ kerning: CGFloat) -> Text {
        return self
    }

    /// Sets the tracking for this text.
    ///
    /// - Parameter tracking: The tracking attribute indicates how much
    ///   additional space, in points, should be added to each character cluster
    ///   after layout. The effect of this attribute is similar to `kerning()`
    ///   but differs in that the added tracking is treated as trailing
    ///   whitespace and a non-zero amount disables non-essential ligatures.
    /// - Returns: Text with the specified amount of tracking.
    ///   If both `kerning()` and `tracking()` are present, `kerning()` will be
    ///   ignored; `tracking()` will still be honored.
    public func tracking(_ tracking: CGFloat) -> Text {
        return self
    }

    /// Sets the baseline offset for this text.
    ///
    /// - Parameter baselineOffset: The amount to shift the text vertically
    ///   (up or down) in relation to its baseline.
    /// - Returns: Text that's above or below its baseline.
    public func baselineOffset(_ baselineOffset: CGFloat) -> Text {
        return self
    }
}
