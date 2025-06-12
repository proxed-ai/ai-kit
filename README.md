# AIKit

A Swift framework providing a standardised API for integrating multiple AI providers into your applications.

## Features

- 🎯 **Unified API**: Single interface for multiple AI providers
- 🔄 **Streaming Support**: Real-time text generation with AsyncSequence
- 🎨 **Model Types**: Support for chat, completion, and embedding models
- 📦 **Modular Design**: Core package with separate provider implementations

## Installation

### Swift Package Manager

Add AIKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/proxed-ai/ai-kit.git", from: "1.0.0")
]
```

## Usage

### Basic Chat Generation

```swift
import AIKit
import AIKitOpenAI // Provider implementation

// Create a provider
let openai = OpenAIProvider(apiKey: "your-api-key")

// Get a chat model
let model = openai.chatModel("gpt-4")

// Generate text
let response = try await generateText(
    model: model,
    messages: [
        .system("You are a helpful assistant"),
        .user("What is Swift?")
    ]
)

print(response.text ?? "")
```

### Streaming Responses

```swift
// Stream text generation
let stream = try await streamText(
    model: model,
    messages: [.user("Tell me a story")],
    maxTokens: 500
)

// Process stream
for try await event in stream {
    switch event {
    case .chunk(let chunk):
        if let content = chunk.choices.first?.delta.content {
            print(content, terminator: "")
        }
    case .done:
        print("\nCompleted!")
    default:
        break
    }
}
```

### Using Message Builder

```swift
var builder = MessageBuilder()
let messages = builder
    .system("You are an expert Swift developer")
    .user("How do I use async/await?")
    .assistant("Here's how to use async/await in Swift...")
    .user("Can you show me an example?")
    .build()

let response = try await generateText(model: model, messages: messages)
```

### Embeddings

```swift
let embeddingModel = openai.embeddingModel("text-embedding-ada-002")

// Single embedding
let embedding = try await embed(
    model: embeddingModel,
    input: "Swift is a powerful programming language"
)

// Batch embeddings
let embeddings = try await embedBatch(
    model: embeddingModel,
    inputs: ["Swift", "Objective-C", "SwiftUI"]
)
```

### Text Completion

```swift
let completionModel = provider.completionModel("gpt4o")

let completion = try await complete(
    model: completionModel,
    prompt: "The Swift programming language was created by",
    maxTokens: 50
)

print(completion.text ?? "")
```

## Creating a Provider

To implement support for a new AI provider, create a package that depends on AIKit:

```swift
import AIKit

public class MyAIProvider: BaseProvider {
    public init(apiKey: String) {
        let config = ProviderConfiguration(
            apiKey: apiKey,
            baseURL: URL(string: "https://api.proxed.ai/v1/openai")!
        )
        super.init(name: "myai", configuration: config)
    }

    public override func chatModel(_ modelId: String) -> any ChatModel {
        return MyAIChatModel(provider: self, modelId: modelId)
    }
}

class MyAIChatModel: ChatModel {
    let provider: AIProvider
    let modelId: String

    func generateText(_ request: ChatRequest) async throws -> ChatResponse {
        // Implementation
    }

    func streamText(_ request: ChatRequest) async throws -> AsyncThrowingStream<ChatStreamEvent, Error> {
        // Implementation
    }
}
```

## Architecture

### Core Components

- **Provider Protocol**: Base interface for AI providers
- **Model Protocols**: ChatModel, CompletionModel, EmbeddingModel
- **Streaming Support**: SSE parser and AsyncSequence integration
- **Error Handling**: Comprehensive error types

### Project Structure

```
AIKit/
├── Sources/
│   └── AIKit/
│       ├── Core/
│       │   ├── Provider.swift
│       │   ├── Models.swift
│       │   ├── BaseProvider.swift
│       │   └── Errors.swift
│       ├── Core/Types/
│       │   ├── Chat.swift
│       │   ├── Completion.swift
│       │   └── Embedding.swift
│       ├── Core/Streaming/
│       │   ├── SSEParser.swift
│       │   ├── StreamingClient.swift
│       │   └── AsyncStreamClient.swift
│       └── AIKit.swift
├── Package.swift
└── README.md
```

## Provider Packages

Separate packages implement specific providers:

- `aikit-openai` - OpenAI and OpenAI-compatible APIs
- `aikit-anthropic` - Anthropic Claude models
- `aikit-gemini` - Google Gemini models
- `aikit-mistral` - Mistral AI models
- More coming soon...

## Requirements

- iOS 17.0+ / macOS 14.0+ / watchOS 10.0+ / tvOS 18.0+
- Swift 5.9+
- Xcode 15.0+

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

AIKit is available under the MIT license. See the LICENSE file for more info.
