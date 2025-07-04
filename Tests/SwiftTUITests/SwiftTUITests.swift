import Testing
@testable import SwiftTUI

@Test func bufferWriteHandlesNegativeIndices() async throws {
    var buffer: [String] = []
    bufferWrite(row: -1, col: 0, text: "test", into: &buffer)
    #expect(buffer.isEmpty)
    
    bufferWrite(row: 0, col: -1, text: "test", into: &buffer)
    #expect(buffer.isEmpty)
}

@Test func bufferWriteExpandsBuffer() async throws {
    var buffer: [String] = []
    bufferWrite(row: 5, col: 10, text: "hello", into: &buffer)
    #expect(buffer.count == 6)
    #expect(buffer[5].count == 15)
    #expect(buffer[5].dropFirst(10).prefix(5) == "hello")
}

@Test func bufferWriteHandlesEmptyText() async throws {
    var buffer: [String] = ["existing"]
    bufferWrite(row: 0, col: 0, text: "", into: &buffer)
    #expect(buffer[0] == "existing")
}

@Test func borderViewHandlesZeroHeight() async throws {
    let text = Text("test")
    let bordered = BorderView(text)
    var buffer: [String] = []
    
    // This should not crash even with zero or negative height
    bordered.paint(origin: (x: 0, y: 0), into: &buffer)
    #expect(buffer.count > 0)
}
