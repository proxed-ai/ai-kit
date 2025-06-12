import Foundation

/// Client for handling streaming responses
public class StreamingClient: NSObject {
    private let session: URLSession
    private var activeTasks: [URLSessionDataTask: Any] = [:]
    private let queue = DispatchQueue(label: "aikit.streaming", attributes: .concurrent)

    public override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 600 // 10 minutes for streaming
        self.session = URLSession(configuration: configuration)
        super.init()
    }

    /// Start a streaming request
    public func stream<T: Decodable>(
        request: URLRequest,
        responseType: T.Type,
        onEvent: @escaping (Result<T, Error>) -> Void,
        onComplete: @escaping (Error?) -> Void
    ) -> URLSessionDataTask {
        let handler = StreamingTaskHandler<T>(
            onEvent: onEvent,
            onComplete: onComplete
        )

        let task = session.dataTask(with: request)

        queue.async(flags: .barrier) {
            self.activeTasks[task] = handler
        }

        // Set up delegate to receive streaming data
        let delegate = StreamingDelegate(client: self, task: task)
        task.delegate = delegate

        task.resume()
        return task
    }

    /// Handle incoming data for a task
    fileprivate func handleData(_ data: Data, for task: URLSessionDataTask) {
        queue.sync {
            if let handler = activeTasks[task] as? StreamingTaskHandlerProtocol {
                handler.handleData(data)
            }
        }
    }

    /// Handle task completion
    fileprivate func handleCompletion(for task: URLSessionDataTask, error: Error?) {
        queue.sync {
            if let handler = activeTasks[task] as? StreamingTaskHandlerProtocol {
                handler.handleCompletion(error: error)
            }
        }

        queue.async(flags: .barrier) {
            self.activeTasks[task] = nil
        }
    }
}

/// Protocol for streaming task handlers
private protocol StreamingTaskHandlerProtocol {
    func handleData(_ data: Data)
    func handleCompletion(error: Error?)
}

/// Handler for individual streaming tasks
private class StreamingTaskHandler<T: Decodable>: StreamingTaskHandlerProtocol {
    private let onEvent: (Result<T, Error>) -> Void
    private let onComplete: (Error?) -> Void
    private var parser: SSEParser!
    private let decoder = JSONDecoder()

    init(
        onEvent: @escaping (Result<T, Error>) -> Void,
        onComplete: @escaping (Error?) -> Void
    ) {
        self.onEvent = onEvent
        self.onComplete = onComplete

        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Initialize parser after self is fully initialized
        self.parser = SSEParser { [weak self] event in
            self?.handleSSEEvent(event)
        }
    }

    func handleData(_ data: Data) {
        parser.parse(data: data)
    }

    func handleCompletion(error: Error?) {
        parser.flush()
        onComplete(error)
    }

    private func handleSSEEvent(_ event: SSEEvent) {
        guard let data = event.data else { return }

        // Skip special events
        if data == "[DONE]" {
            return
        }

        do {
            guard let jsonData = data.data(using: .utf8) else {
                throw AIKitError.invalidResponse("Invalid UTF-8 data")
            }

            let decoded = try decoder.decode(T.self, from: jsonData)
            onEvent(.success(decoded))
        } catch {
            onEvent(.failure(AIKitError.decodingError(error)))
        }
    }
}

/// URLSession delegate for streaming
private class StreamingDelegate: NSObject, URLSessionDataDelegate {
    weak var client: StreamingClient?
    let task: URLSessionDataTask

    init(client: StreamingClient, task: URLSessionDataTask) {
        self.client = client
        self.task = task
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.handleData(data, for: task)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let dataTask = task as? URLSessionDataTask {
            client?.handleCompletion(for: dataTask, error: error)
        }
    }
}

// Helper type for generic decoding
private struct AnyCodable: Decodable {
    let decoder: Decoder

    init(from decoder: Decoder) throws {
        self.decoder = decoder
    }
}
