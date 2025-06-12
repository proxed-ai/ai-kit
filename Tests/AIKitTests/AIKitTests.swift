import XCTest
@testable import AIKit

final class AIKitTests: XCTestCase {

    func testMockProvider() async throws {
        // Create mock provider
        let provider = MockProvider()

        // Test chat model
        let chatModel = provider.chatModel("mock-chat")

        let response = try await generateText(
            model: chatModel,
            messages: [
                .system("You are a helpful assistant"),
                .user("Hello, world!")
            ]
        )

        XCTAssertNotNil(response.text)
        XCTAssertEqual(response.choices.count, 1)
        XCTAssertNotNil(response.usage)
    }

    func testStreamingChat() async throws {
        let provider = MockProvider()
        let chatModel = provider.chatModel("mock-chat")

        let stream = try await streamText(
            model: chatModel,
            messages: [.user("Tell me a story")]
        )

        var receivedText = ""
        var eventCount = 0

        for try await event in stream {
            eventCount += 1
            switch event {
            case .chunk(let chunk):
                if let content = chunk.choices.first?.delta.content {
                    receivedText += content
                }
            case .done:
                break
            default:
                break
            }
        }

        XCTAssertGreaterThan(eventCount, 0)
        XCTAssertFalse(receivedText.isEmpty)
    }

    func testMessageBuilder() {
        let builder = MessageBuilder()
        let messages = builder
            .system("System prompt")
            .user("User message")
            .assistant("Assistant response")
            .build()

        XCTAssertEqual(messages.count, 3)
        XCTAssertEqual(messages[0].role, ChatRole.system)
        XCTAssertEqual(messages[1].role, ChatRole.user)
        XCTAssertEqual(messages[2].role, ChatRole.assistant)
    }

    func testCompletion() async throws {
        let provider = MockProvider()
        let completionModel = provider.completionModel("mock-completion")

        let response = try await complete(
            model: completionModel,
            prompt: "Swift",
            maxTokens: 100
        )

        XCTAssertNotNil(response.text)
        XCTAssertFalse(response.text!.isEmpty)
    }

    func testEmbedding() async throws {
        let provider = MockProvider()
        let embeddingModel = provider.embeddingModel("mock-embedding")

        let response = try await embed(
            model: embeddingModel,
            input: "Test embedding"
        )

        XCTAssertEqual(response.data.count, 1)
        XCTAssertNotNil(response.data.first?.embedding.floatArray)
    }

    func testBatchEmbedding() async throws {
        let provider = MockProvider()
        let embeddingModel = provider.embeddingModel("mock-embedding")

        let response = try await embedBatch(
            model: embeddingModel,
            inputs: ["First", "Second", "Third"]
        )

        XCTAssertEqual(response.data.count, 3)
    }

    func testErrorHandling() {
        let error = AIKitError.rateLimitExceeded(retryAfter: 60)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("60"))
    }

    func testSSEParser() {
        var events: [SSEEvent] = []
        let parser = SSEParser { event in
            events.append(event)
        }

        let data = """
        event: message
        data: {"text": "Hello"}

        data: {"text": "World"}

        """.data(using: .utf8)!

        parser.parse(data: data)
        parser.flush()

        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events[0].event, "message")
        XCTAssertEqual(events[0].data, "{\"text\": \"Hello\"}")
        XCTAssertNil(events[1].event)
        XCTAssertEqual(events[1].data, "{\"text\": \"World\"}")
    }
}
