import Foundation

// MARK: - Chat Generation

/// Generate text from a chat conversation
public func generateText(
    model: any ChatModel,
    messages: [ChatMessage],
    temperature: Double? = nil,
    maxTokens: Int? = nil,
    topP: Double? = nil,
    frequencyPenalty: Double? = nil,
    presencePenalty: Double? = nil,
    stop: [String]? = nil,
    tools: [Tool]? = nil,
    toolChoice: ToolChoice? = nil,
    responseFormat: ResponseFormat? = nil,
    seed: Int? = nil,
    user: String? = nil
) async throws -> ChatResponse {
    let request = ChatRequest(
        messages: messages,
        temperature: temperature,
        maxTokens: maxTokens,
        topP: topP,
        frequencyPenalty: frequencyPenalty,
        presencePenalty: presencePenalty,
        stop: stop,
        stream: false,
        tools: tools,
        toolChoice: toolChoice,
        responseFormat: responseFormat,
        seed: seed,
        user: user
    )

    return try await model.generateText(request)
}

/// Stream text generation from a chat conversation
public func streamText(
    model: any ChatModel,
    messages: [ChatMessage],
    temperature: Double? = nil,
    maxTokens: Int? = nil,
    topP: Double? = nil,
    frequencyPenalty: Double? = nil,
    presencePenalty: Double? = nil,
    stop: [String]? = nil,
    tools: [Tool]? = nil,
    toolChoice: ToolChoice? = nil,
    responseFormat: ResponseFormat? = nil,
    seed: Int? = nil,
    user: String? = nil
) async throws -> AsyncThrowingStream<ChatStreamEvent, Error> {
    let request = ChatRequest(
        messages: messages,
        temperature: temperature,
        maxTokens: maxTokens,
        topP: topP,
        frequencyPenalty: frequencyPenalty,
        presencePenalty: presencePenalty,
        stop: stop,
        stream: true,
        tools: tools,
        toolChoice: toolChoice,
        responseFormat: responseFormat,
        seed: seed,
        user: user
    )

    return try await model.streamText(request)
}

// MARK: - Text Completion

/// Complete the given prompt
public func complete(
    model: any CompletionModel,
    prompt: String,
    temperature: Double? = nil,
    maxTokens: Int? = nil,
    topP: Double? = nil,
    frequencyPenalty: Double? = nil,
    presencePenalty: Double? = nil,
    stop: [String]? = nil,
    suffix: String? = nil,
    logprobs: Int? = nil,
    echo: Bool? = nil,
    seed: Int? = nil,
    user: String? = nil
) async throws -> CompletionResponse {
    let request = CompletionRequest(
        prompt: prompt,
        temperature: temperature,
        maxTokens: maxTokens,
        topP: topP,
        frequencyPenalty: frequencyPenalty,
        presencePenalty: presencePenalty,
        stop: stop,
        stream: false,
        suffix: suffix,
        logprobs: logprobs,
        echo: echo,
        seed: seed,
        user: user
    )

    return try await model.complete(request)
}

/// Stream completion for the given prompt
public func streamCompletion(
    model: any CompletionModel,
    prompt: String,
    temperature: Double? = nil,
    maxTokens: Int? = nil,
    topP: Double? = nil,
    frequencyPenalty: Double? = nil,
    presencePenalty: Double? = nil,
    stop: [String]? = nil,
    suffix: String? = nil,
    logprobs: Int? = nil,
    echo: Bool? = nil,
    seed: Int? = nil,
    user: String? = nil
) async throws -> AsyncThrowingStream<CompletionStreamEvent, Error> {
    let request = CompletionRequest(
        prompt: prompt,
        temperature: temperature,
        maxTokens: maxTokens,
        topP: topP,
        frequencyPenalty: frequencyPenalty,
        presencePenalty: presencePenalty,
        stop: stop,
        stream: true,
        suffix: suffix,
        logprobs: logprobs,
        echo: echo,
        seed: seed,
        user: user
    )

    return try await model.streamCompletion(request)
}

// MARK: - Embeddings

/// Generate embeddings for the given input
public func embed(
    model: any EmbeddingModel,
    input: String,
    dimensions: Int? = nil,
    encodingFormat: EncodingFormat? = nil,
    user: String? = nil
) async throws -> EmbeddingResponse {
    let request = EmbeddingRequest(
        input: .text(input),
        dimensions: dimensions,
        encodingFormat: encodingFormat,
        user: user
    )

    return try await model.embed(request)
}

/// Generate embeddings for multiple inputs
public func embedBatch(
    model: any EmbeddingModel,
    inputs: [String],
    dimensions: Int? = nil,
    encodingFormat: EncodingFormat? = nil,
    user: String? = nil
) async throws -> EmbeddingResponse {
    let request = EmbeddingRequest(
        input: .texts(inputs),
        dimensions: dimensions,
        encodingFormat: encodingFormat,
        user: user
    )

    return try await model.embed(request)
}

// MARK: - Convenience Builders

/// Builder for creating chat messages
public struct MessageBuilder {
    private var messages: [ChatMessage]

    public init() {
        self.messages = []
    }

    /// Add a system message
    public func system(_ content: String) -> MessageBuilder {
        var builder = self
        builder.messages.append(.system(content))
        return builder
    }

    /// Add a user message
    public func user(_ content: String) -> MessageBuilder {
        var builder = self
        builder.messages.append(.user(content))
        return builder
    }

    /// Add an assistant message
    public func assistant(_ content: String) -> MessageBuilder {
        var builder = self
        builder.messages.append(.assistant(content))
        return builder
    }

    /// Add a custom message
    public func message(_ message: ChatMessage) -> MessageBuilder {
        var builder = self
        builder.messages.append(message)
        return builder
    }

    /// Build the message array
    public func build() -> [ChatMessage] {
        return messages
    }
}

// MARK: - Response Extensions

public extension ChatResponse {
    /// Get the first message content as text
    var text: String? {
        choices.first?.message.content.text
    }

    /// Get all message contents as text
    var allTexts: [String] {
        choices.compactMap { $0.message.content.text }
    }
}

public extension CompletionResponse {
    /// Get the first completion text
    var text: String? {
        choices.first?.text
    }

    /// Get all completion texts
    var allTexts: [String] {
        choices.map { $0.text }
    }
}

public extension MessageContent {
    /// Get text content if available
    var text: String? {
        switch self {
        case .text(let string):
            return string
        case .multipart(let parts):
            return parts.compactMap { $0.text }.joined()
        }
    }
}
