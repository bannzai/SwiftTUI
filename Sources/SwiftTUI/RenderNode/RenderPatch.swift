/// RenderPatch：レンダリングの差分を表す型
///
/// このファイルには、RenderNodeの差分計算結果を表現する型が定義されています。
/// 効率的な部分更新を実現するため、変更された部分のみを記録します。

import Foundation

/// レンダリングの変更を表すパッチ
///
/// RenderNodeの差分計算で生成される、変更内容を記述する列挙型です。
/// 各ケースは特定の種類の変更を表し、必要な情報を保持します。
public enum RenderPatch {
  /// フレームが変更された
  case frameChanged(id: ObjectIdentifier, from: Frame, to: Frame)
  
  /// 属性が変更された
  case attributesChanged(id: ObjectIdentifier, from: RenderAttributes, to: RenderAttributes)
  
  /// 子ノードが変更された（追加/削除/並び替え）
  case childrenChanged(id: ObjectIdentifier)
  
  /// 特定のセルが変更された
  case cellChanged(x: Int, y: Int, from: Cell, to: Cell)
  
  /// ノードが追加された
  case nodeAdded(id: ObjectIdentifier, node: RenderNode)
  
  /// ノードが削除された
  case nodeRemoved(id: ObjectIdentifier)
  
  /// ノードの内容が変更された（詳細な変更は別のパッチで表現）
  case contentChanged(id: ObjectIdentifier)
}

// MARK: - Equatable

extension RenderPatch: Equatable {
  public static func == (lhs: RenderPatch, rhs: RenderPatch) -> Bool {
    switch (lhs, rhs) {
    case let (.frameChanged(id1, from1, to1), .frameChanged(id2, from2, to2)):
      return id1 == id2 && from1 == from2 && to1 == to2
    case let (.attributesChanged(id1, from1, to1), .attributesChanged(id2, from2, to2)):
      return id1 == id2 && from1 == from2 && to1 == to2
    case let (.childrenChanged(id1), .childrenChanged(id2)):
      return id1 == id2
    case let (.cellChanged(x1, y1, from1, to1), .cellChanged(x2, y2, from2, to2)):
      return x1 == x2 && y1 == y2 && from1 == from2 && to1 == to2
    case let (.nodeAdded(id1, node1), .nodeAdded(id2, node2)):
      // RenderNodeは参照型なので、同じインスタンスかどうかで比較
      return id1 == id2 && node1 === node2
    case let (.nodeRemoved(id1), .nodeRemoved(id2)):
      return id1 == id2
    case let (.contentChanged(id1), .contentChanged(id2)):
      return id1 == id2
    default:
      return false
    }
  }
}

// MARK: - Patch Application

/// パッチを適用するためのヘルパー構造体
public struct RenderPatchApplier {
  /// パッチのリストを適用
  ///
  /// - Parameters:
  ///   - patches: 適用するパッチのリスト
  ///   - buffer: 適用先のセルバッファ
  ///   - nodeMap: ノードIDとRenderNodeのマッピング
  public static func apply(
    patches: [RenderPatch],
    to buffer: inout CellBuffer,
    nodeMap: [ObjectIdentifier: RenderNode]
  ) {
    for patch in patches {
      apply(patch: patch, to: &buffer, nodeMap: nodeMap)
    }
  }
  
  /// 単一のパッチを適用
  private static func apply(
    patch: RenderPatch,
    to buffer: inout CellBuffer,
    nodeMap: [ObjectIdentifier: RenderNode]
  ) {
    switch patch {
    case let .frameChanged(id, from, to):
      // フレーム変更：古い領域をクリアして新しい領域に再描画
      clearFrame(from, in: &buffer)
      if let node = nodeMap[id] {
        node.render(into: &buffer)
      }
      
    case let .attributesChanged(id, _, _):
      // 属性変更：ノード全体を再描画
      if let node = nodeMap[id] {
        node.render(into: &buffer)
      }
      
    case let .childrenChanged(id):
      // 子ノード変更：ノード全体を再描画
      if let node = nodeMap[id] {
        node.render(into: &buffer)
      }
      
    case let .cellChanged(x, y, _, to):
      // セル変更：特定のセルのみ更新
      buffer.setCell(row: y, col: x, cell: to)
      
    case let .nodeAdded(_, node):
      // ノード追加：新しいノードを描画
      node.render(into: &buffer)
      
    case let .nodeRemoved(id):
      // ノード削除：ノードの領域をクリア
      if let node = nodeMap[id] {
        clearFrame(node.frame, in: &buffer)
      }
      
    case let .contentChanged(id):
      // コンテンツ変更：ノードを再描画
      if let node = nodeMap[id] {
        node.render(into: &buffer)
      }
    }
  }
  
  /// フレーム領域をクリア
  private static func clearFrame(_ frame: Frame, in buffer: inout CellBuffer) {
    let clearCell = Cell(character: " ")
    for y in frame.y..<frame.maxY {
      for x in frame.x..<frame.maxX {
        buffer.setCell(row: y, col: x, cell: clearCell)
      }
    }
  }
}

// MARK: - Patch Optimization

/// パッチの最適化を行うユーティリティ
public struct RenderPatchOptimizer {
  /// パッチリストを最適化
  ///
  /// 重複するパッチや無効なパッチを削除し、効率的な適用順序に並べ替えます。
  ///
  /// - Parameter patches: 最適化するパッチのリスト
  /// - Returns: 最適化されたパッチのリスト
  public static func optimize(_ patches: [RenderPatch]) -> [RenderPatch] {
    var optimized: [RenderPatch] = []
    var processedNodes: Set<ObjectIdentifier> = []
    
    // パッチを種類ごとにグループ化
    var frameChanges: [ObjectIdentifier: (Frame, Frame)] = [:]
    var attributeChanges: [ObjectIdentifier: (RenderAttributes, RenderAttributes)] = [:]
    var cellChanges: [String: Cell] = [:] // "x,y" をキーとして使用
    var otherPatches: [RenderPatch] = []
    
    for patch in patches {
      switch patch {
      case let .frameChanged(id, from, to):
        frameChanges[id] = (from, to)
        
      case let .attributesChanged(id, from, to):
        attributeChanges[id] = (from, to)
        
      case let .cellChanged(x, y, _, to):
        cellChanges["\(x),\(y)"] = to
        
      default:
        otherPatches.append(patch)
      }
    }
    
    // フレーム変更を先に適用（大きな変更）
    for (id, (from, to)) in frameChanges {
      optimized.append(.frameChanged(id: id, from: from, to: to))
      processedNodes.insert(id)
    }
    
    // 属性変更を適用（中程度の変更）
    for (id, (from, to)) in attributeChanges {
      // フレーム変更がある場合は、属性変更は不要（全体が再描画される）
      if !processedNodes.contains(id) {
        optimized.append(.attributesChanged(id: id, from: from, to: to))
      }
    }
    
    // その他のパッチを適用
    optimized.append(contentsOf: otherPatches)
    
    // セル変更を最後に適用（最小単位の変更）
    for (key, cell) in cellChanges {
      let components = key.split(separator: ",")
      if components.count == 2,
         let x = Int(components[0]),
         let y = Int(components[1]) {
        // TODO: 前の値を保持する必要がある
        optimized.append(.cellChanged(x: x, y: y, from: Cell(character: " "), to: cell))
      }
    }
    
    return optimized
  }
  
  /// パッチが有効かどうかを判定
  public static func isValid(_ patch: RenderPatch) -> Bool {
    switch patch {
    case let .frameChanged(_, from, to):
      return from != to
      
    case let .attributesChanged(_, from, to):
      return from != to
      
    case let .cellChanged(_, _, from, to):
      return from != to
      
    default:
      return true
    }
  }
}

// MARK: - Debugging

extension RenderPatch: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .frameChanged(id, from, to):
      return "FrameChanged(\(id): \(from) → \(to))"
      
    case let .attributesChanged(id, _, _):
      return "AttributesChanged(\(id))"
      
    case let .childrenChanged(id):
      return "ChildrenChanged(\(id))"
      
    case let .cellChanged(x, y, from, to):
      return "CellChanged((\(x),\(y)): '\(from.character)' → '\(to.character)')"
      
    case let .nodeAdded(id, _):
      return "NodeAdded(\(id))"
      
    case let .nodeRemoved(id):
      return "NodeRemoved(\(id))"
      
    case let .contentChanged(id):
      return "ContentChanged(\(id))"
    }
  }
}