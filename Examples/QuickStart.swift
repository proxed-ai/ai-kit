import AIKit
import Foundation

// MARK: - Quick Start Example

func quickStartExample() async throws {
    // 1. Create a provider (using MockProvider for this example)
    let provider = MockProvider()

    // 2. Get a chat model
    let chatModel = provider.chatModel("mock-chat")

    // 3. Generate text with a simple conversation
    print("=== Simple Chat Generation ===")
    let response = try await generateText(
        model: chatModel,
        messages: [
            .system("You are a helpful assistant"),
            .user("What is Swift?")
        ]
    )
    print("Response: \(response.text ?? "")")

    // 4. Using the MessageBuilder for more complex conversations
    print("\n=== Using MessageBuilder ===")
    let builder = MessageBuilder()
    let conversation = builder
        .system("You are an expert Swift developer")
        .user("How do I create a protocol in Swift?")
        .assistant("To create a protocol in Swift, use the `protocol` keyword...")
        .user("Can you show me an example with associated types?")
        .build()

    let detailedResponse = try await generateText(
        model: chatModel,
        messages: conversation
    )
    print("Response: \(detailedResponse.text ?? "")")

    // 5. Streaming responses
    print("\n=== Streaming Response ===")
    let stream = try await streamText(
        model: chatModel,
        messages: [.user("Tell me a story about AI")]
    )

    print("Streaming: ", terminator: "")
    for try await event in stream {
        switch event {
        case .chunk(let chunk):
            if let content = chunk.choices.first?.delta.content {
                print(content, terminator: "")
            }
        case .done:
            print("\n[Stream completed]")
        default:
            break
        }
    }

    // 6. Text completion
    print("\n=== Text Completion ===")
    let completionModel = provider.completionModel("mock-completion")
    let completion = try await complete(
        model: completionModel,
        prompt: "The Swift programming language",
        maxTokens: 50
    )
    print("Completion: \(completion.text ?? "")")

    // 7. Embeddings
    print("\n=== Embeddings ===")
    let embeddingModel = provider.embeddingModel("mock-embedding")

    // Single embedding
    let embedding = try await embed(
        model: embeddingModel,
        input: "Swift is a powerful programming language"
    )
    print("Generated embedding with dimension: \(embedding.data.first?.embedding.floatArray?.count ?? 0)")

    // Batch embeddings
    let batchEmbeddings = try await embedBatch(
        model: embeddingModel,
        inputs: ["Swift", "Objective-C", "SwiftUI", "UIKit"]
    )
    print("Generated \(batchEmbeddings.data.count) embeddings")
}

// MARK: - Advanced Example with Error Handling

func advancedExample() async {
    do {
        let provider = MockProvider()
        let chatModel = provider.chatModel("advanced-model")

        // Example with all parameters
        let response = try await generateText(
            model: chatModel,
            messages: [
                .system("You are a helpful coding assistant"),
                .user("Write a function to sort an array")
            ],
            temperature: 0.7,
            maxTokens: 500,
            topP: 0.9,
            frequencyPenalty: 0.1,
            presencePenalty: 0.1,
            stop: ["```", "// End"],
            seed: 42
        )

        print("Generated code:\n\(response.text ?? "")")

        // Usage information
        if let usage = response.usage {
            print("\nToken usage:")
            print("- Prompt tokens: \(usage.promptTokens)")
            print("- Completion tokens: \(usage.completionTokens)")
            print("- Total tokens: \(usage.totalTokens)")
        }

    } catch AIKitError.rateLimitExceeded(let retryAfter) {
        print("Rate limit exceeded. Retry after: \(retryAfter ?? 0) seconds")
    } catch AIKitError.invalidAPIKey {
        print("Invalid API key")
    } catch AIKitError.modelNotFound(let model) {
        print("Model not found: \(model)")
    } catch {
        print("Error: \(error)")
    }
}

// MARK: - Real Provider Example (pseudo-code)

func realProviderExample() async throws {
    // This is how you would use a real provider like OpenAI
    // (Requires the aikit-openai package)

    /*
    import AIKitOpenAI

    let openai = OpenAIProvider(apiKey: "your-api-key")
    let model = openai.chatModel("gpt-4")

    let response = try await generateText(
        model: model,
        messages: [
            .system("You are a helpful assistant"),
            .user("Explain quantum computing in simple terms")
        ]
    )

    print(response.text ?? "")
    */
}

// MARK: - Custom Provider Implementation Example

/// Example of how to implement a custom provider
class CustomProvider: BaseProvider {
    init(apiKey: String) {
        let config = ProviderConfiguration(
            apiKey: apiKey,
            baseURL: URL(string: "https://api.custom-ai.com/v1")!
        )
        super.init(name: "custom", configuration: config)
    }

    override func chatModel(_ modelId: String) -> any ChatModel {
        return CustomChatModel(provider: self, modelId: modelId)
    }
}

class CustomChatModel: ChatModel {
    let provider: any AIProvider
    let modelId: String

    init(provider: any AIProvider, modelId: String) {
        self.provider = provider
        self.modelId = modelId
    }

    func generateText(_ request: ChatRequest) async throws -> ChatResponse {
        // Implementation would make HTTP request to your API
        fatalError("Implement your custom logic here")
    }

    func streamText(_ request: ChatRequest) async throws -> AsyncThrowingStream<ChatStreamEvent, Error> {
        // Implementation would stream from your API
        fatalError("Implement your custom streaming logic here")
    }
}
