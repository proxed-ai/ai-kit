import Foundation

/// Errors that can occur when using AIKit
public enum AIKitError: LocalizedError {
    case providerNotConfigured(String)
    case invalidAPIKey
    case invalidURL(String)
    case invalidResponse(String)
    case networkError(Error)
    case rateLimitExceeded(retryAfter: TimeInterval?)
    case quotaExceeded
    case invalidRequest(String)
    case authenticationFailed(String)
    case modelNotFound(String)
    case contextLengthExceeded(maxTokens: Int)
    case contentFiltered(reason: String)
    case streamingError(String)
    case decodingError(Error)
    case unknownError(String)
    case providerError(code: String?, message: String)

    public var errorDescription: String? {
        switch self {
        case .providerNotConfigured(let provider):
            return "Provider '\(provider)' is not properly configured"
        case .invalidAPIKey:
            return "Invalid or missing API key"
        case .invalidURL(let url):
            return "Invalid URL: \(url)"
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .rateLimitExceeded(let retryAfter):
            if let retryAfter = retryAfter {
                return "Rate limit exceeded. Retry after \(retryAfter) seconds"
            }
            return "Rate limit exceeded"
        case .quotaExceeded:
            return "API quota exceeded"
        case .invalidRequest(let message):
            return "Invalid request: \(message)"
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .modelNotFound(let model):
            return "Model '\(model)' not found"
        case .contextLengthExceeded(let maxTokens):
            return "Context length exceeded. Maximum tokens: \(maxTokens)"
        case .contentFiltered(let reason):
            return "Content filtered: \(reason)"
        case .streamingError(let message):
            return "Streaming error: \(message)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .unknownError(let message):
            return "Unknown error: \(message)"
        case .providerError(let code, let message):
            if let code = code {
                return "Provider error [\(code)]: \(message)"
            }
            return "Provider error: \(message)"
        }
    }
}

/// HTTP status codes for error handling
public struct HTTPStatusCode {
    public static let ok = 200
    public static let created = 201
    public static let accepted = 202
    public static let noContent = 204
    public static let badRequest = 400
    public static let unauthorized = 401
    public static let forbidden = 403
    public static let notFound = 404
    public static let conflict = 409
    public static let unprocessableEntity = 422
    public static let tooManyRequests = 429
    public static let internalServerError = 500
    public static let badGateway = 502
    public static let serviceUnavailable = 503
    public static let gatewayTimeout = 504
}
