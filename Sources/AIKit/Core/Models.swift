import Foundation

// MARK: - Base Model Protocol

/// Base protocol for all AI models
public protocol AIModel {
    /// The model identifier
    var modelId: String { get }

    /// The provider that created this model
    var provider: any AIProvider { get }
}

// MARK: - Chat Model

/// Protocol for chat-based language models
public protocol ChatModel: AIModel {
    /// Generate text from a chat conversation
    func generateText(_ request: ChatRequest) async throws -> ChatResponse

    /// Stream text generation from a chat conversation
    func streamText(_ request: ChatRequest) async throws -> AsyncThrowingStream<ChatStreamEvent, Error>
}

// MARK: - Completion Model

/// Protocol for text completion models
public protocol CompletionModel: AIModel {
    /// Complete the given prompt
    func complete(_ request: CompletionRequest) async throws -> CompletionResponse

    /// Stream completion for the given prompt
    func streamCompletion(_ request: CompletionRequest) async throws -> AsyncThrowingStream<CompletionStreamEvent, Error>
}

// MARK: - Embedding Model

/// Protocol for embedding models
public protocol EmbeddingModel: AIModel {
    /// Generate embeddings for the given inputs
    func embed(_ request: EmbeddingRequest) async throws -> EmbeddingResponse
}
