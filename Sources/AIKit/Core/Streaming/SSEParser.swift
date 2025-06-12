import Foundation

/// Parser for Server-Sent Events (SSE) streams
public class SSEParser {
    private var buffer = ""
    private let onEvent: (SSEEvent) -> Void

    public init(onEvent: @escaping (SSEEvent) -> Void) {
        self.onEvent = onEvent
    }

    /// Parse incoming data chunk
    public func parse(data: Data) {
        guard let text = String(data: data, encoding: .utf8) else { return }
        buffer += text
        processBuffer()
    }

    /// Process buffered data and emit events
    private func processBuffer() {
        let lines = buffer.components(separatedBy: "\n")

        // Keep last incomplete line in buffer
        if !buffer.hasSuffix("\n") && lines.count > 1 {
            buffer = lines.last ?? ""
        } else {
            buffer = ""
        }

        var currentEvent = SSEEvent()

        for line in lines.dropLast(buffer.isEmpty ? 0 : 1) {
            if line.isEmpty {
                // Empty line indicates end of event
                if !currentEvent.isEmpty {
                    onEvent(currentEvent)
                    currentEvent = SSEEvent()
                }
            } else if line.hasPrefix(":") {
                // Comment, ignore
                continue
            } else if let colonIndex = line.firstIndex(of: ":") {
                let field = String(line[..<colonIndex])
                var value = String(line[line.index(after: colonIndex)...])

                // Remove leading space if present
                if value.hasPrefix(" ") {
                    value = String(value.dropFirst())
                }

                switch field {
                case "event":
                    currentEvent.event = value
                case "data":
                    if currentEvent.data == nil {
                        currentEvent.data = value
                    } else {
                        currentEvent.data! += "\n" + value
                    }
                case "id":
                    currentEvent.id = value
                case "retry":
                    currentEvent.retry = Int(value)
                default:
                    break
                }
            }
        }
    }

    /// Flush any remaining buffered data
    public func flush() {
        if !buffer.isEmpty {
            processBuffer()
        }
    }
}

/// Server-Sent Event
public struct SSEEvent {
    public var event: String?
    public var data: String?
    public var id: String?
    public var retry: Int?

    var isEmpty: Bool {
        event == nil && data == nil && id == nil && retry == nil
    }
}
