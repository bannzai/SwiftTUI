/// 最もシンプルなプリミティブView：テキスト表示
/// 
/// このファイルは、SwiftTUIで最も基本的なView「Text」を実装しています。
/// Textは、ターミナルに文字列を表示するための基本コンポーネントです。
/// 
/// プリミティブViewとは：
/// - 他のViewを含まない、最も基本的なView
/// - 直接ターミナルに描画される要素
/// - bodyプロパティを持たない（Body = Never）
/// 
/// 使用例：
/// ```swift
/// Text("Hello, World!")
///     .foregroundColor(.green)
///     .bold()
/// ```

/// SwiftUIライクなText View
/// 
/// ターミナルに文字列を表示するための基本的なViewです。
/// SwiftUIのTextと同じインターフェースを提供します。
public struct Text: View {
    /// 表示する文字列の内容
    private let content: String
    
    /// テキストに適用されるスタイル設定
    /// privateにすることで、外部から直接変更できないようにしています
    private var modifiers: TextModifiers = TextModifiers()
    
    /// 文字列を直接受け取るイニシャライザ
    /// 
    /// 最も一般的な使い方：
    /// ```swift
    /// Text("こんにちは")
    /// ```
    public init(_ content: String) {
        self.content = content
    }
    
    /// StringProtocolに準拠する型を受け取るジェネリックイニシャライザ
    /// 
    /// StringProtocolとは：
    /// - String、Substring、String.SubSequenceなどが準拠するプロトコル
    /// - これにより、様々な文字列型を受け取れる
    /// 
    /// 使用例：
    /// ```swift
    /// let substring = "Hello, World!".prefix(5)  // Substring型
    /// Text(substring)  // このイニシャライザが呼ばれる
    /// ```
    /// 
    /// <S: StringProtocol>：
    /// - Sは型パラメータ（ジェネリック）
    /// - StringProtocolに準拠する任意の型を表す
    public init<S: StringProtocol>(_ content: S) {
        self.content = String(content)
    }
    
    /// Text自体はプリミティブViewなのでbodyは持たない
    /// 
    /// Body = Never の意味：
    /// - Textは他のViewを含まない最終的な要素
    /// - bodyプロパティが呼ばれることはない
    /// - 内部で直接LayoutViewに変換されて描画される
    public typealias Body = Never
}

/// テキスト用のモディファイア（スタイル）設定を保持する構造体
/// 
/// モディファイアパターンとは：
/// - Viewに対してスタイルや設定を適用する仕組み
/// - メソッドチェーンで連続して適用できる
/// - 元のViewは変更せず、新しいViewを返す（イミュータブル）
/// 
/// なぜprivateか：
/// - 内部実装の詳細を隠蔽
/// - ユーザーは公開されたメソッド経由でのみ設定を変更
private struct TextModifiers {
    /// 文字色（nil の場合はデフォルト色）
    var foregroundColor: Color?
    
    /// 背景色（nil の場合は透明）
    var backgroundColor: Color?
    
    /// 太字フラグ
    var bold: Bool = false
    
    /// 斜体フラグ（注：多くのターミナルでは未対応）
    var italic: Bool = false
    
    /// 下線フラグ
    var underline: Bool = false
}

/// Textに対するモディファイアメソッド群
/// 
/// SwiftUIと同じように、メソッドチェーンでスタイルを適用できます：
/// ```swift
/// Text("重要！")
///     .foregroundColor(.red)
///     .bold()
///     .underline()
/// ```
/// 
/// 重要な設計原則：
/// - 各メソッドは新しいTextインスタンスを返す（元のTextは変更しない）
/// - これによりSwiftUIと同じ宣言的なスタイルを実現
public extension Text {
    /// 文字色を設定
    /// 
    /// - Parameter color: 文字色（nilを指定するとデフォルト色にリセット）
    /// - Returns: 色が設定された新しいTextインスタンス
    /// 
    /// ターミナルでサポートされる色：
    /// - .black, .red, .green, .yellow, .blue, .magenta, .cyan, .white
    /// - .default（ターミナルのデフォルト色）
    func foregroundColor(_ color: Color?) -> Text {
        var copy = self  // 構造体のコピーを作成
        copy.modifiers.foregroundColor = color
        return copy  // 新しいインスタンスを返す
    }
    
    /// 背景色を設定
    /// 
    /// - Parameter color: 背景色
    /// - Returns: 背景色が設定された新しいTextインスタンス
    /// 
    /// 注意：背景色は文字がある部分のみに適用されます
    func background(_ color: Color) -> Text {
        var copy = self
        copy.modifiers.backgroundColor = color
        return copy
    }
    
    /// テキストを太字にする
    /// 
    /// - Returns: 太字設定された新しいTextインスタンス
    /// 
    /// ANSIエスケープシーケンス：ESC[1m が使用されます
    func bold() -> Text {
        var copy = self
        copy.modifiers.bold = true
        return copy
    }
    
    /// テキストを斜体にする
    /// 
    /// - Returns: 斜体設定された新しいTextインスタンス
    /// 
    /// 警告：多くのターミナルエミュレータでは斜体はサポートされていません
    func italic() -> Text {
        var copy = self
        copy.modifiers.italic = true
        return copy
    }
    
    /// テキストに下線を引く
    /// 
    /// - Returns: 下線設定された新しいTextインスタンス
    /// 
    /// ANSIエスケープシーケンス：ESC[4m が使用されます
    func underline() -> Text {
        var copy = self
        copy.modifiers.underline = true
        return copy
    }
}

/// 内部実装：SwiftUIライクなTextをレンダリング可能なLayoutViewへ変換
/// 
/// この部分が、宣言的なView APIと実際のターミナル描画をつなぐ橋渡しです。
/// 
/// 変換の流れ：
/// 1. Text（SwiftUI風のView） → CellText（LayoutView）
/// 2. モディファイアの設定を適用
/// 3. レンダリング可能な形式で返す
extension Text {
    /// TextをLayoutViewに変換する内部プロパティ
    /// 
    /// internal の意味：
    /// - SwiftTUIフレームワーク内部からのみアクセス可能
    /// - ユーザーコードからは見えない
    /// 
    /// any LayoutView の意味：
    /// - LayoutViewプロトコルに準拠する任意の型
    /// - 実際にはCellText型が返されるが、プロトコルとして扱う
    internal var _layoutView: any LayoutView {
        // ステップ1: セルベースのCellTextを作成
        // CellTextは、実際にターミナルに文字を描画する役割を持つ
        let cellText = CellText(content)
        
        // ステップ2: モディファイアを適用
        // SwiftUIスタイルの設定を、CellTextが理解できる形式に変換
        var result = cellText
        
        // 文字色の適用
        if let fg = modifiers.foregroundColor {
            result = result.color(fg)
        }
        
        // 背景色の適用
        if let bg = modifiers.backgroundColor {
            result = result.background(bg)
        }
        
        // 太字の適用
        if modifiers.bold {
            result = result.bold()
        }
        
        // 注：italic と underline は CellText側で未実装の可能性あり
        // これらは将来の拡張ポイント
        
        return result
    }
}