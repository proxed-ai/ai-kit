import Foundation

/// Modern async/await streaming client
public actor AsyncStreamClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    /// Stream response data using AsyncThrowingStream
    public func stream<T: Decodable>(
        request: URLRequest,
        responseType: T.Type
    ) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let (bytes, response) = try await session.bytes(for: request)

                    // Check response status
                    if let httpResponse = response as? HTTPURLResponse {
                        guard (200...299).contains(httpResponse.statusCode) else {
                            throw AIKitError.unknownError("HTTP \(httpResponse.statusCode)")
                        }
                    }

                    let parser = SSEParser { event in
                        self.handleSSEEvent(event, responseType: responseType, continuation: continuation)
                    }

                    // Process streaming data
                    for try await data in bytes {
                        parser.parse(data: Data([data]))
                    }

                    parser.flush()
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func handleSSEEvent<T: Decodable>(
        _ event: SSEEvent,
        responseType: T.Type,
        continuation: AsyncThrowingStream<T, Error>.Continuation
    ) {
        guard let data = event.data else { return }

        // Skip special events
        if data == "[DONE]" {
            return
        }

        do {
            guard let jsonData = data.data(using: .utf8) else {
                throw AIKitError.invalidResponse("Invalid UTF-8 data")
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            let decoded = try decoder.decode(responseType, from: jsonData)
            continuation.yield(decoded)
        } catch {
            // Log decoding errors but don't stop the stream
            print("Decoding error: \(error)")
        }
    }
}

// MARK: - Stream Transformation Extensions

public extension AsyncThrowingStream where Element: Decodable {
    /// Transform stream elements to a different type
    func map<T>(_ transform: @escaping (Element) throws -> T) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream<T, Error> { continuation in
            Task {
                do {
                    for try await element in self {
                        let transformed = try transform(element)
                        continuation.yield(transformed)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    /// Filter stream elements
    func filter(_ isIncluded: @escaping (Element) throws -> Bool) -> AsyncThrowingStream<Element, Error> {
        AsyncThrowingStream<Element, Error> { continuation in
            Task {
                do {
                    for try await element in self {
                        if try isIncluded(element) {
                            continuation.yield(element)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// MARK: - Chat Stream Helpers

public extension AsyncThrowingStream where Element == ChatStreamEvent {
    /// Extract only text content from chat stream
    var textStream: AsyncThrowingStream<String, Error> {
        self.compactMap { event in
            switch event {
            case .chunk(let chunk):
                return chunk.choices.first?.delta.content
            default:
                return nil
            }
        }
    }

    /// Accumulate all text from the stream
    func accumulatedText() async throws -> String {
        var result = ""
        for try await text in textStream {
            result += text
        }
        return result
    }
}

// MARK: - Completion Stream Helpers

public extension AsyncThrowingStream where Element == CompletionStreamEvent {
    /// Extract only text content from completion stream
    var textStream: AsyncThrowingStream<String, Error> {
        self.compactMap { event in
            switch event {
            case .chunk(let chunk):
                return chunk.choices.first?.text
            default:
                return nil
            }
        }
    }
}

// MARK: - Utility Extensions

private extension AsyncThrowingStream {
    /// Compact map for AsyncThrowingStream
    func compactMap<T>(_ transform: @escaping (Element) throws -> T?) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream<T, Error> { continuation in
            Task {
                do {
                    for try await element in self {
                        if let transformed = try transform(element) {
                            continuation.yield(transformed)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
