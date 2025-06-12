import Foundation

// MARK: - JSON Encoding/Decoding for Any types

/// Extension to make Tool conform to Codable with proper Any handling
extension Tool {
    enum CodingKeys: String, CodingKey {
        case type
        case function
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)

        // Decode function with Any parameters
        let functionContainer = try container.nestedContainer(keyedBy: ToolFunction.CodingKeys.self, forKey: .function)
        let name = try functionContainer.decode(String.self, forKey: .name)
        let description = try functionContainer.decodeIfPresent(String.self, forKey: .description)

        var parameters: [String: Any]? = nil
        if let parametersData = try? functionContainer.decode(Data.self, forKey: .parameters),
           let json = try? JSONSerialization.jsonObject(with: parametersData) as? [String: Any] {
            parameters = json
        }

        function = ToolFunction(name: name, description: description, parameters: parameters)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(function, forKey: .function)
    }
}

extension ToolFunction {
    enum CodingKeys: String, CodingKey {
        case name
        case description
        case parameters
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)

        if let parametersData = try? container.decode(Data.self, forKey: .parameters),
           let json = try? JSONSerialization.jsonObject(with: parametersData) as? [String: Any] {
            parameters = json
        } else {
            parameters = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)

        if let parameters = parameters {
            let data = try JSONSerialization.data(withJSONObject: parameters)
            try container.encode(data, forKey: .parameters)
        }
    }
}

// MARK: - ToolChoice Codable

extension ToolChoice {
    private enum CodingKeys: String, CodingKey {
        case type
        case function
    }

    private enum ToolChoiceType: String, Codable {
        case none
        case auto
        case required
        case function
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ToolChoiceType.self, forKey: .type)

        switch type {
        case .none:
            self = .none
        case .auto:
            self = .auto
        case .required:
            self = .required
        case .function:
            let functionName = try container.decode(String.self, forKey: .function)
            self = .function(name: functionName)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .none:
            try container.encode(ToolChoiceType.none, forKey: .type)
        case .auto:
            try container.encode(ToolChoiceType.auto, forKey: .type)
        case .required:
            try container.encode(ToolChoiceType.required, forKey: .type)
        case .function(let name):
            try container.encode(ToolChoiceType.function, forKey: .type)
            try container.encode(name, forKey: .function)
        }
    }
}

// MARK: - ResponseFormat Codable

extension ResponseFormat {
    private enum CodingKeys: String, CodingKey {
        case type
        case jsonSchema
    }

    private enum ResponseFormatType: String, Codable {
        case text
        case jsonObject = "json_object"
        case jsonSchema = "json_schema"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ResponseFormatType.self, forKey: .type)

        switch type {
        case .text:
            self = .text
        case .jsonObject:
            self = .jsonObject
        case .jsonSchema:
            if let schemaData = try? container.decode(Data.self, forKey: .jsonSchema),
               let schema = try? JSONSerialization.jsonObject(with: schemaData) as? [String: Any] {
                self = .jsonSchema(schema: schema)
            } else {
                throw DecodingError.dataCorruptedError(forKey: .jsonSchema, in: container, debugDescription: "Invalid JSON schema")
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .text:
            try container.encode(ResponseFormatType.text, forKey: .type)
        case .jsonObject:
            try container.encode(ResponseFormatType.jsonObject, forKey: .type)
        case .jsonSchema(let schema):
            try container.encode(ResponseFormatType.jsonSchema, forKey: .type)
            let schemaData = try JSONSerialization.data(withJSONObject: schema)
            try container.encode(schemaData, forKey: .jsonSchema)
        }
    }
}

// MARK: - Utility Extensions

public extension Dictionary where Key == String, Value == Any {
    /// Convert dictionary to JSON data
    func toJSONData() throws -> Data {
        try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }

    /// Create dictionary from JSON data
    static func fromJSONData(_ data: Data) throws -> [String: Any]? {
        try JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
}

public extension Encodable {
    /// Convert to dictionary representation
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
}
