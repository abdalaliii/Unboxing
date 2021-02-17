import XCTest
@testable import Unboxing

final class DecodedArrayTests: XCTestCase {

  struct Person: Decodable {
    let name: String
  }

  func testDecodingWithDynamicKeys() throws {
    let barJson = """
        {
            "1": {
              "name": "john"
            },
            "2": {
              "name": "smith"
            }
        }
        """.data(using: .utf8)!

    let contactList = try JSONDecoder().decode(DecodedArray<Person>.self, from: barJson)

    XCTAssertEqual(contactList.count, 2)
    XCTAssertEqual(contactList[0].name, "john")
    XCTAssertEqual(contactList[1].name, "smith")
  }

  static var allTests = [
    ("testDecodingWithDynamicKeys", testDecodingWithDynamicKeys),
  ]
}
