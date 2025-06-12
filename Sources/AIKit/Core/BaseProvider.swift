import Foundation

/// Base implementation for AI providers with common functionality
open class BaseProvider: AIProvider {
    public let name: String
    public let configuration: ProviderConfiguration

    public init(name: String, configuration: ProviderConfiguration) {
        self.name = name
        self.configuration = configuration
    }

    // MARK: - Model Creation

    open func chatModel(_ modelId: String) -> any ChatModel {
        fatalError("Chat models not implemented for \(name)")
    }

    open func completionModel(_ modelId: String) -> any CompletionModel {
        fatalError("Completion models not implemented for \(name)")
    }

    open func embeddingModel(_ modelId: String) -> any EmbeddingModel {
        fatalError("Embedding models not implemented for \(name)")
    }

    // MARK: - HTTP Client

    /// Build URL with query parameters
    public func buildURL(path: String, queryItems: [URLQueryItem] = []) throws -> URL {
        guard let baseURL = configuration.baseURL else {
            throw AIKitError.invalidURL("No base URL configured")
        }

        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw AIKitError.invalidURL(path)
        }

        // Add provider query params
        var allQueryItems = queryItems
        for (key, value) in configuration.queryParams {
            allQueryItems.append(URLQueryItem(name: key, value: value))
        }

        if !allQueryItems.isEmpty {
            components.queryItems = allQueryItems
        }

        guard let url = components.url else {
            throw AIKitError.invalidURL(components.string ?? path)
        }

        return url
    }

    /// Build HTTP headers including authentication
    public func buildHeaders(additionalHeaders: [String: String] = [:]) -> [String: String] {
        var headers = configuration.headers

        // Add API key if present
        if let apiKey = configuration.apiKey {
            headers["Authorization"] = "Bearer \(apiKey)"
        }

        // Add additional headers
        for (key, value) in additionalHeaders {
            headers[key] = value
        }

        // Set default content type if not present
        if headers["Content-Type"] == nil {
            headers["Content-Type"] = "application/json"
        }

        return headers
    }

    /// Create URLRequest with common configuration
    public func createRequest(
        url: URL,
        method: String = "POST",
        headers: [String: String]? = nil,
        body: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body

        let finalHeaders = headers ?? buildHeaders()
        for (key, value) in finalHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    /// Handle HTTP response and check for errors
    public func handleResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIKitError.invalidResponse("Invalid HTTP response")
        }

        switch httpResponse.statusCode {
        case 200...299:
            // Success
            return
        case HTTPStatusCode.unauthorized:
            throw AIKitError.authenticationFailed("Invalid API key")
        case HTTPStatusCode.tooManyRequests:
            let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                .flatMap { TimeInterval($0) }
            throw AIKitError.rateLimitExceeded(retryAfter: retryAfter)
        case HTTPStatusCode.notFound:
            throw AIKitError.modelNotFound("Resource not found")
        default:
            // Try to parse error from response
            if let errorInfo = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = errorInfo["error"] as? String ?? errorInfo["message"] as? String {
                throw AIKitError.providerError(
                    code: errorInfo["code"] as? String,
                    message: message
                )
            }
            throw AIKitError.unknownError("HTTP \(httpResponse.statusCode)")
        }
    }

    // MARK: - JSON Encoding/Decoding

    /// JSON encoder with common configuration
    public lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    /// JSON decoder with common configuration
    public lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
