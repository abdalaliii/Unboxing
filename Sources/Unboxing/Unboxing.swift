import Foundation

enum PolymorphicError: Error {
    case unableToFindPolymorphicType
    case unableToRepresentAsPolymorphic
}

/// Discriminator key enum used to retrieve discriminator fields in JSON payloads.
public enum Discriminator: String, CodingKey {
    case type = "type"
    case modelType = "modelType"
    case code = "code"
}

/// To support a new class family, create an enum that conforms to this protocol and contains the parseable types.
public protocol ClassFamily: Decodable {
    associatedtype BaseType : Decodable

    /// The discriminator key.
    static var discriminator: Discriminator { get }

    /// Returns the class type of the object coresponding to the value.
    func getType() -> BaseType.Type
}

public extension KeyedDecodingContainer {

    /// Decode a heterogeneous list of objects for a given family.
    /// - Parameters:
    ///     - heterogeneousType: The decodable type of the list.
    ///     - family: The ClassFamily enum for the type family.
    ///     - key: The CodingKey to look up the list in the current container.
    /// - Returns: The resulting list of heterogeneousType elements.
    func decodeHeterogeneousArray<F : ClassFamily>(OfFamily family: F.Type, forKey key: K) throws -> [F.BaseType] {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        var containerCopy = container
        var elements = [F.BaseType]()

        while !container.isAtEnd {
            let typeContainer = try container.nestedContainer(keyedBy: Discriminator.self)
            guard let family = try? typeContainer.decode(F.self, forKey: F.discriminator) else {
                throw PolymorphicError.unableToFindPolymorphicType
            }
            let type = family.getType()

            guard let decoded = try? containerCopy.decode(type) else {
                throw PolymorphicError.unableToRepresentAsPolymorphic
            }

            elements.append(decoded)
        }

        return elements
    }
}

extension JSONDecoder {
    /// Decode a heterogeneous list of objects.
    /// - Parameters:
    ///     - family: The ClassFamily enum type to decode with.
    ///     - data: The data to decode.
    /// - Returns: The list of decoded objects.
    func decodeHeterogeneousArray<F: ClassFamily>(OfFamily: F.Type, from data: Data) throws -> [F.BaseType] {
        return try self.decode([ClassWrapper<F>].self, from: data).compactMap { $0.object }
    }

    private class ClassWrapper<T: ClassFamily>: Decodable {
        /// The family enum containing the class information.
        let family: T
        /// The decoded object. Can be any subclass of U.
        let object: T.BaseType?

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Discriminator.self)
            // Decode the family with the discriminator.
            guard let type = try? container.decode(T.self, forKey: T.discriminator) else {
                throw PolymorphicError.unableToFindPolymorphicType
            }
            family = type
            // Decode the object by initialising the corresponding type.
            object = try family.getType().init(from: decoder)
        }
    }
}

