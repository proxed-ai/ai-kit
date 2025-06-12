import Foundation

/// Base protocol for AI providers
public protocol AIProvider {
    /// The name of the provider (e.g., "openai", "anthropic")
    var name: String { get }

    /// Base configuration for the provider
    var configuration: ProviderConfiguration { get }

    /// Create a chat model instance
    func chatModel(_ modelId: String) -> any ChatModel

    /// Create a completion model instance
    func completionModel(_ modelId: String) -> any CompletionModel

    /// Create an embedding model instance
    func embeddingModel(_ modelId: String) -> any EmbeddingModel
}

/// Configuration for AI providers
public struct ProviderConfiguration {
    /// API key for authentication
    public let apiKey: String?

    /// Base URL for API calls
    public let baseURL: URL?

    /// Custom headers to include in requests
    public let headers: [String: String]

    /// Custom query parameters to include in requests
    public let queryParams: [String: String]

    /// Custom URLSession configuration
    public let urlSession: URLSession

    public init(
        apiKey: String? = nil,
        baseURL: URL? = nil,
        headers: [String: String] = [:],
        queryParams: [String: String] = [:],
        urlSession: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.headers = headers
        self.queryParams = queryParams
        self.urlSession = urlSession
    }
}
