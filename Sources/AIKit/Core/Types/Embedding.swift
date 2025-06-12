import Foundation

// MARK: - Embedding Request

/// Request for generating embeddings
public struct EmbeddingRequest {
    public let input: EmbeddingInput
    public let model: String?
    public let dimensions: Int?
    public let encodingFormat: EncodingFormat?
    public let user: String?
    public let metadata: [String: Any]?

    public init(
        input: EmbeddingInput,
        model: String? = nil,
        dimensions: Int? = nil,
        encodingFormat: EncodingFormat? = nil,
        user: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.input = input
        self.model = model
        self.dimensions = dimensions
        self.encodingFormat = encodingFormat
        self.user = user
        self.metadata = metadata
    }
}

/// Input for embedding generation
public enum EmbeddingInput {
    case text(String)
    case texts([String])
    case tokens([Int])
    case tokenArrays([[Int]])
}

/// Encoding format for embeddings
public enum EncodingFormat: String, Codable {
    case float = "float"
    case base64 = "base64"
}

// MARK: - Embedding Response

/// Response from embedding generation
public struct EmbeddingResponse {
    public let data: [EmbeddingData]
    public let model: String
    public let usage: EmbeddingUsage?
    public let metadata: [String: Any]?

    public init(
        data: [EmbeddingData],
        model: String,
        usage: EmbeddingUsage? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.data = data
        self.model = model
        self.usage = usage
        self.metadata = metadata
    }
}

public struct EmbeddingData {
    public let index: Int
    public let embedding: EmbeddingVector

    public init(index: Int, embedding: EmbeddingVector) {
        self.index = index
        self.embedding = embedding
    }
}

/// Vector representation of an embedding
public enum EmbeddingVector {
    case float([Float])
    case base64(String)

    /// Get the float representation of the embedding
    public var floatArray: [Float]? {
        switch self {
        case .float(let array):
            return array
        case .base64(let string):
            // Would need to decode base64 to float array
            return nil
        }
    }
}

public struct EmbeddingUsage: Codable {
    public let promptTokens: Int
    public let totalTokens: Int

    public init(promptTokens: Int, totalTokens: Int) {
        self.promptTokens = promptTokens
        self.totalTokens = totalTokens
    }
}
