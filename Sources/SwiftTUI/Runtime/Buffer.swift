/// 共有バッファに安全に文字列を書き込む
/// - Parameters:
///   - row: 行番号（0-origin）
///   - col: 列番号（0-origin）
///   - text: 挿入する文字列（ANSI 可）
@inline(__always)
func bufferWrite(row: Int, col: Int, text: String, into buf: inout [String]) {

  // ガード：負値を許さない
  guard row >= 0, col >= 0 else { return }

  // 行数を確保
  while buf.count <= row { buf.append("") }

  // 行を配列化
  var line = Array(buf[row])

  // 左側スペース
  if line.count < col {
    line += Array(repeating: " ", count: col - line.count)
  }

  // 右側スペース
  let after = col + text.count
  if line.count < after {
    line += Array(repeating: " ", count: after - line.count)
  }

  // 上書き
  let chars = Array(text)
  for i in 0..<chars.count {
    line[col + i] = chars[i]
  }
  buf[row] = String(line)
}
