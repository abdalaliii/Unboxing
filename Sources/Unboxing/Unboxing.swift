import Foundation

/// Discriminator key enum used to retrieve discriminator fields in JSON payloads.
public enum Discriminator: String, CodingKey {
    case type = "type"
    case modelType = "modelType"
    case code = "code"
}

/// To support a new class family, create an enum that conforms to this protocol and contains the different types.
public protocol ClassFamily: Decodable {
    /// The discriminator key.
    static var discriminator: Discriminator { get }

    /// Returns the class type of the object coresponding to the value.
    func getType() -> AnyObject.Type
}

public extension KeyedDecodingContainer {

    /// Decode a heterogeneous list of objects for a given family.
    /// - Parameters:
    ///     - heterogeneousType: The decodable type of the list.
    ///     - family: The ClassFamily enum for the type family.
    ///     - key: The CodingKey to look up the list in the current container.
    /// - Returns: The resulting list of heterogeneousType elements.
    public func decode<T : Decodable, U : ClassFamily>(_ heterogeneousType: [T].Type, ofFamily family: U.Type, forKey key: K) throws -> [T] {
        var container = try self.nestedUnkeyedContainer(forKey: key)
        var list = [T]()
        var tmpContainer = container
        while !container.isAtEnd {
            let typeContainer = try container.nestedContainer(keyedBy: Discriminator.self)
            let family: U = try typeContainer.decode(U.self, forKey: U.discriminator)
            if let type = family.getType() as? T.Type {
                list.append(try tmpContainer.decode(type))
            }
        }
        return list
    }
}
