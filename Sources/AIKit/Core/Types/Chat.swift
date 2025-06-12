import Foundation

// MARK: - Chat Messages

/// Role in a chat conversation
public enum ChatRole: String, Codable {
    case system
    case user
    case assistant
    case function
    case tool
}

/// A message in a chat conversation
public struct ChatMessage: Codable {
    public let role: ChatRole
    public let content: MessageContent
    public let name: String?
    public let functionCall: FunctionCall?
    public let toolCalls: [ToolCall]?

    public init(
        role: ChatRole,
        content: MessageContent,
        name: String? = nil,
        functionCall: FunctionCall? = nil,
        toolCalls: [ToolCall]? = nil
    ) {
        self.role = role
        self.content = content
        self.name = name
        self.functionCall = functionCall
        self.toolCalls = toolCalls
    }

    /// Convenience initializer for text messages
    public static func user(_ text: String) -> ChatMessage {
        ChatMessage(role: .user, content: .text(text))
    }

    public static func assistant(_ text: String) -> ChatMessage {
        ChatMessage(role: .assistant, content: .text(text))
    }

    public static func system(_ text: String) -> ChatMessage {
        ChatMessage(role: .system, content: .text(text))
    }
}

/// Content of a message
public enum MessageContent: Codable {
    case text(String)
    case multipart([ContentPart])

    // Custom coding to handle different content types
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let text = try? container.decode(String.self) {
            self = .text(text)
        } else if let parts = try? container.decode([ContentPart].self) {
            self = .multipart(parts)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "MessageContent must be either String or [ContentPart]"
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let text):
            try container.encode(text)
        case .multipart(let parts):
            try container.encode(parts)
        }
    }
}

/// A part of multipart content
public struct ContentPart: Codable {
    public enum PartType: String, Codable {
        case text
        case image
        case audio
        case video
    }

    public let type: PartType
    public let text: String?
    public let imageUrl: URL?
    public let audioUrl: URL?
    public let videoUrl: URL?
    public let mimeType: String?

    public init(
        type: PartType,
        text: String? = nil,
        imageUrl: URL? = nil,
        audioUrl: URL? = nil,
        videoUrl: URL? = nil,
        mimeType: String? = nil
    ) {
        self.type = type
        self.text = text
        self.imageUrl = imageUrl
        self.audioUrl = audioUrl
        self.videoUrl = videoUrl
        self.mimeType = mimeType
    }
}

// MARK: - Function/Tool Calling

public struct FunctionCall: Codable {
    public let name: String
    public let arguments: String

    public init(name: String, arguments: String) {
        self.name = name
        self.arguments = arguments
    }
}

public struct ToolCall: Codable {
    public let id: String
    public let type: String
    public let function: FunctionCall

    public init(id: String, type: String = "function", function: FunctionCall) {
        self.id = id
        self.type = type
        self.function = function
    }
}

// MARK: - Chat Request

/// Request for chat generation
public struct ChatRequest {
    public let messages: [ChatMessage]
    public let model: String?
    public let temperature: Double?
    public let maxTokens: Int?
    public let topP: Double?
    public let frequencyPenalty: Double?
    public let presencePenalty: Double?
    public let stop: [String]?
    public let stream: Bool
    public let tools: [Tool]?
    public let toolChoice: ToolChoice?
    public let responseFormat: ResponseFormat?
    public let seed: Int?
    public let user: String?
    public let metadata: [String: Any]?

    public init(
        messages: [ChatMessage],
        model: String? = nil,
        temperature: Double? = nil,
        maxTokens: Int? = nil,
        topP: Double? = nil,
        frequencyPenalty: Double? = nil,
        presencePenalty: Double? = nil,
        stop: [String]? = nil,
        stream: Bool = false,
        tools: [Tool]? = nil,
        toolChoice: ToolChoice? = nil,
        responseFormat: ResponseFormat? = nil,
        seed: Int? = nil,
        user: String? = nil,
        metadata: [String: Any]? = nil
    ) {
        self.messages = messages
        self.model = model
        self.temperature = temperature
        self.maxTokens = maxTokens
        self.topP = topP
        self.frequencyPenalty = frequencyPenalty
        self.presencePenalty = presencePenalty
        self.stop = stop
        self.stream = stream
        self.tools = tools
        self.toolChoice = toolChoice
        self.responseFormat = responseFormat
        self.seed = seed
        self.user = user
        self.metadata = metadata
    }
}

// MARK: - Tool Definition

public struct Tool: Codable {
    public let type: String
    public let function: ToolFunction

    public init(type: String = "function", function: ToolFunction) {
        self.type = type
        self.function = function
    }
}

public struct ToolFunction: Codable {
    public let name: String
    public let description: String?
    public let parameters: [String: Any]?

    public init(name: String, description: String? = nil, parameters: [String: Any]? = nil) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}

public enum ToolChoice: Codable {
    case none
    case auto
    case required
    case function(name: String)

    // Custom coding implementation would be needed
}

// MARK: - Response Format

public enum ResponseFormat: Codable {
    case text
    case jsonObject
    case jsonSchema(schema: [String: Any])
}

// MARK: - Chat Response

/// Response from chat generation
public struct ChatResponse {
    public let id: String
    public let choices: [ChatChoice]
    public let usage: Usage?
    public let model: String
    public let systemFingerprint: String?
    public let metadata: [String: Any]?

    public init(
        id: String,
        choices: [ChatChoice],
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

public struct ChatChoice {
    public let index: Int
    public let message: ChatMessage
    public let finishReason: FinishReason?
    public let logprobs: LogProbs?

    public init(
        index: Int,
        message: ChatMessage,
        finishReason: FinishReason? = nil,
        logprobs: LogProbs? = nil
    ) {
        self.index = index
        self.message = message
        self.finishReason = finishReason
        self.logprobs = logprobs
    }
}

// MARK: - Streaming

/// Events emitted during chat streaming
public enum ChatStreamEvent {
    case chunk(ChatStreamChunk)
    case metadata([String: Any])
    case error(Error)
    case done
}

public struct ChatStreamChunk {
    public let id: String
    public let choices: [ChatStreamChoice]
    public let model: String?
    public let systemFingerprint: String?

    public init(
        id: String,
        choices: [ChatStreamChoice],
        model: String? = nil,
        systemFingerprint: String? = nil
    ) {
        self.id = id
        self.choices = choices
        self.model = model
        self.systemFingerprint = systemFingerprint
    }
}

public struct ChatStreamChoice {
    public let index: Int
    public let delta: ChatMessageDelta
    public let finishReason: FinishReason?
    public let logprobs: LogProbs?

    public init(
        index: Int,
        delta: ChatMessageDelta,
        finishReason: FinishReason? = nil,
        logprobs: LogProbs? = nil
    ) {
        self.index = index
        self.delta = delta
        self.finishReason = finishReason
        self.logprobs = logprobs
    }
}

public struct ChatMessageDelta {
    public let role: ChatRole?
    public let content: String?
    public let functionCall: FunctionCall?
    public let toolCalls: [ToolCall]?

    public init(
        role: ChatRole? = nil,
        content: String? = nil,
        functionCall: FunctionCall? = nil,
        toolCalls: [ToolCall]? = nil
    ) {
        self.role = role
        self.content = content
        self.functionCall = functionCall
        self.toolCalls = toolCalls
    }
}

// MARK: - Common Types

public enum FinishReason: String, Codable {
    case stop
    case length
    case contentFilter = "content_filter"
    case toolCalls = "tool_calls"
    case functionCall = "function_call"
}

public struct Usage: Codable {
    public let promptTokens: Int
    public let completionTokens: Int
    public let totalTokens: Int

    public init(promptTokens: Int, completionTokens: Int, totalTokens: Int) {
        self.promptTokens = promptTokens
        self.completionTokens = completionTokens
        self.totalTokens = totalTokens
    }
}

public struct LogProbs: Codable {
    // Implementation depends on provider specifics
}
