import XCTest
@testable import Unboxing

final class DecodedArrayTests: XCTestCase {

  struct Person: Decodable {
    let name: String
  }

  func testDecodingWithDynamicKeys() throws {
    let json = """
        {
            "1": {
              "name": "john"
            },
            "2": {
              "name": "smith"
            }
        }
        """.data(using: .utf8)!

    let contactList = try JSONDecoder().decode(DecodedArray<Person>.self, from: json)
    XCTAssertEqual(contactList.count, 2)
  }

  static var allTests = [
    ("testDecodingWithDynamicKeys", testDecodingWithDynamicKeys),
  ]
}
