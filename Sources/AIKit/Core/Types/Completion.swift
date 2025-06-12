import Foundation

// MARK: - Completion Request

/// Request for text completion
public struct CompletionRequest {
    public let prompt: String
    public let model: String?
    public let temperature: Double?
    public let maxTokens: Int?
    public let topP: Double?
    public let frequencyPenalty: Double?
    public let presencePenalty: Double?
    public let stop: [String]?
    public let stream: Bool
    public let suffix: String?
    public let logprobs: Int?
    public let echo: Bool?
    public let seed: Int?
    public let user: String?
    public let metadata: [String: Any]?

    public init(
        prompt: String,
        model: String? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil,
        topP: Double? = nil,
        frequencyPenalty: Double? = nil,
        presencePenalty: Double? = nil,
        stop: [String]? = nil,
        stream: Bool = false,
        suffix: String? = nil,
        logprobs: Int? = nil,
        echo: Bool? = nil,
        seed: Int? = nil,
        user: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.prompt = prompt
        self.model = model
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.topP = topP
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.stop = stop
        self.stream = stream
        self.suffix = suffix
        self.logprobs = logprobs
        self.echo = echo
        self.seed = seed
        self.user = user
        self.metadata = metadata
    }
}

// MARK: - Completion Response

/// Response from text completion
public struct CompletionResponse {
    public let id: String
    public let choices: [CompletionChoice]
    public let usage: Usage?
    public let model: String
    public let systemFingerprint: String?
    public let metadata: [String: Any]?

    public init(
        id: String,
        choices: [CompletionChoice],
        usage: Usage? = nil,
        model: String,
        systemFingerprint: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.id = id
        self.choices = choices
        self.usage = usage
        self.model = model
        self.systemFingerprint = systemFingerprint
        self.metadata = metadata
    }
}

public struct CompletionChoice {
    public let index: Int
    public let text: String
    public let finishReason: FinishReason?
    public let logprobs: LogProbs?

    public init(
        index: Int,
        text: String,
        finishReason: FinishReason? = nil,
        logprobs: LogProbs? = nil
    ) {
        self.index = index
        self.text = text
        self.finishReason = finishReason
        self.logprobs = logprobs
    }
}

// MARK: - Streaming

/// Events emitted during completion streaming
public enum CompletionStreamEvent {
    case chunk(CompletionStreamChunk)
    case metadata([String: Any])
    case error(Error)
    case done
}

public struct CompletionStreamChunk {
    public let id: String
    public let choices: [CompletionStreamChoice]
    public let model: String?
    public let systemFingerprint: String?

    public init(
        id: String,
        choices: [CompletionStreamChoice],
        model: String? = nil,
        systemFingerprint: String? = nil
    ) {
        self.id = id
        self.choices = choices
        self.model = model
        self.systemFingerprint = systemFingerprint
    }
}

public struct CompletionStreamChoice {
    public let index: Int
    public let text: String
    public let finishReason: FinishReason?
    public let logprobs: LogProbs?

    public init(
        index: Int,
        text: String,
        finishReason: FinishReason? = nil,
        logprobs: LogProbs? = nil
    ) {
        self.index = index
        self.text = text
        self.finishReason = finishReason
        self.logprobs = logprobs
    }
}
