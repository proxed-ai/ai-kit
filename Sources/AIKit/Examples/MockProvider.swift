import Foundation

/// Example mock provider for testing and demonstration
public class MockProvider: BaseProvider {
    public init() {
        let config = ProviderConfiguration()
        super.init(name: "mock", configuration: config)
    }

    public override func chatModel(_ modelId: String) -> any ChatModel {
        return MockChatModel(provider: self, modelId: modelId)
    }

    public override func completionModel(_ modelId: String) -> any CompletionModel {
        return MockCompletionModel(provider: self, modelId: modelId)
    }

    public override func embeddingModel(_ modelId: String) -> any EmbeddingModel {
        return MockEmbeddingModel(provider: self, modelId: modelId)
    }
}

// MARK: - Mock Chat Model

class MockChatModel: ChatModel {
    let provider: any AIProvider
    let modelId: String

    init(provider: any AIProvider, modelId: String) {
        self.provider = provider
        self.modelId = modelId
    }

    func generateText(_ request: ChatRequest) async throws -> ChatResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        let responseText = "This is a mock response to: \(request.messages.last?.content.text ?? "no message")"

        return ChatResponse(
            id: "mock-\(UUID().uuidString)",
            choices: [
                ChatChoice(
                    index: 0,
                    message: .assistant(responseText),
                    finishReason: .stop
                )
            ],
            usage: Usage(
                promptTokens: 10,
                completionTokens: 15,
                totalTokens: 25
            ),
            model: modelId
        )
    }

    func streamText(_ request: ChatRequest) async throws -> AsyncThrowingStream<ChatStreamEvent, Error> {
        AsyncThrowingStream { continuation in
            Task {
                let words = "This is a streaming mock response".components(separatedBy: " ")

                for (index, word) in words.enumerated() {
                    // Simulate streaming delay
                    try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

                    let chunk = ChatStreamChunk(
                        id: "mock-stream-\(UUID().uuidString)",
                        choices: [
                            ChatStreamChoice(
                                index: 0,
                                delta: ChatMessageDelta(
                                    content: word + (index < words.count - 1 ? " " : "")
                                )
                            )
                        ],
                        model: modelId
                    )

                    continuation.yield(.chunk(chunk))
                }

                continuation.yield(.done)
                continuation.finish()
            }
        }
    }
}

// MARK: - Mock Completion Model

class MockCompletionModel: CompletionModel {
    let provider: any AIProvider
    let modelId: String

    init(provider: any AIProvider, modelId: String) {
        self.provider = provider
        self.modelId = modelId
    }

    func complete(_ request: CompletionRequest) async throws -> CompletionResponse {
        try await Task.sleep(nanoseconds: 500_000_000)

        let completion = " is a powerful and intuitive programming language."

        return CompletionResponse(
            id: "mock-completion-\(UUID().uuidString)",
            choices: [
                CompletionChoice(
                    index: 0,
                    text: completion,
                    finishReason: .stop
                )
            ],
            usage: Usage(
                promptTokens: 5,
                completionTokens: 10,
                totalTokens: 15
            ),
            model: modelId
        )
    }

    func streamCompletion(_ request: CompletionRequest) async throws -> AsyncThrowingStream<CompletionStreamEvent, Error> {
        AsyncThrowingStream { continuation in
            Task {
                let text = " is amazing!"

                for char in text {
                    try await Task.sleep(nanoseconds: 50_000_000)

                    let chunk = CompletionStreamChunk(
                        id: "mock-stream-\(UUID().uuidString)",
                        choices: [
                            CompletionStreamChoice(
                                index: 0,
                                text: String(char)
                            )
                        ],
                        model: modelId
                    )

                    continuation.yield(.chunk(chunk))
                }

                continuation.yield(.done)
                continuation.finish()
            }
        }
    }
}

// MARK: - Mock Embedding Model

class MockEmbeddingModel: EmbeddingModel {
    let provider: any AIProvider
    let modelId: String

    init(provider: any AIProvider, modelId: String) {
        self.provider = provider
        self.modelId = modelId
    }

    func embed(_ request: EmbeddingRequest) async throws -> EmbeddingResponse {
        try await Task.sleep(nanoseconds: 300_000_000)

        let dimension = request.dimensions ?? 1536

        switch request.input {
        case .text(let text):
            return createResponse(for: [text], dimension: dimension)
        case .texts(let texts):
            return createResponse(for: texts, dimension: dimension)
        case .tokens, .tokenArrays:
            // For simplicity, return mock embeddings
            return createResponse(for: ["mock"], dimension: dimension)
        }
    }

    private func createResponse(for texts: [String], dimension: Int) -> EmbeddingResponse {
        let embeddings = texts.enumerated().map { index, _ in
            // Generate mock embedding vector
            let vector = (0..<dimension).map { _ in Float.random(in: -1...1) }
            return EmbeddingData(
                index: index,
                embedding: .float(vector)
            )
        }

        return EmbeddingResponse(
            data: embeddings,
            model: modelId,
            usage: EmbeddingUsage(
                promptTokens: texts.count * 10,
                totalTokens: texts.count * 10
            )
        )
    }
}
