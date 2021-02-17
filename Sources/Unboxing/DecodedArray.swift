import Foundation

/// Decode an array of objects with dynamic keys
struct DecodedArray<T: Decodable>: Decodable {
  typealias ArrayType = [T]
  private var array: ArrayType

  /// Needed for creating decoding container from JSONDecoder
  private struct DynamicKey: CodingKey {

    var stringValue: String
    init?(stringValue: String) {
      self.stringValue = stringValue
    }

    var intValue: Int?
    init?(intValue: Int) {
      return nil
    }
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicKey.self)
    var tmpArray = ArrayType()

    for key in container.allKeys {
      let decodedObject = try container.decode(T.self, forKey: DynamicKey(stringValue: key.stringValue)!)
      tmpArray.append(decodedObject)
    }

    array = tmpArray
  }
}

extension DecodedArray: Collection {
  typealias Index = ArrayType.Index
  typealias Element = ArrayType.Element

  var startIndex: ArrayType.Index {
    return array.startIndex
  }

  var endIndex: ArrayType.Index {
    return array.endIndex
  }

  subscript(index: Index) -> Iterator.Element {
    get {
      return array[index]
    }
  }

  func index(after i: Index) -> Index {
    return array.index(after: i)
  }
}
