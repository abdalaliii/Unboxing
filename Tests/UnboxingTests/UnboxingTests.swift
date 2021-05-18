import XCTest
@testable import Unboxing

class Drink: Decodable {
  let type: String
  let description: String
}

class Soda: Drink {
  var sugar_content: String

  private enum CodingKeys: String, CodingKey {
    case sugar_content
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.sugar_content = try container.decode(String.self, forKey: .sugar_content)
    try super.init(from: decoder)
  }
}

class Bar: Decodable {
  let drinks: [Drink]
  
  private enum CodingKeys: String, CodingKey {
    case drinks
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    drinks = try container.decodeHeterogeneousArray(OfFamily: DrinkFamily.self, forKey: .drinks)
  }
}

enum DrinkFamily: String, ClassFamily {
  
  typealias BaseType = Drink
  
  case drink = "drink"
  case soda = "soda"
  
  static var discriminator: Discriminator = .type
  
  func getType() -> Drink.Type {
    switch self {
      case .soda:
        return Soda.self
      case .drink:
        return Drink.self
    }
  }
}

final class UnboxingTests: XCTestCase {
  
    func testDecodingObjectWithHeterogenousJson() throws {
        let json = """
        {
            "drinks":
            [
                {"type": "drink", "description": "All natural"},
                {"type": "soda", "description": "best drunk on fridays after work", "sugar_content": "5%"}
            ]
        }
        """.data(using: .utf8)!

        let bar = try JSONDecoder().decode(Bar.self, from: json)

        XCTAssertEqual(bar.drinks.count, 2)
        XCTAssertNotNil(bar.drinks[1] as? Soda)
        XCTAssertEqual((bar.drinks[1] as! Soda).sugar_content, "5%")
    }

    func testDecodingUnavailableTypeInHeterogenousJson() throws {
        let json = """
        {
            "drinks":
            [
                {"type": "drink", "description": "All natural"},
                {"type": "beer", "description": "best drunk on fridays after work", "sugar_content": "5%"}
            ]
        }
        """.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(Bar.self, from: json))
    }
  
  func testDecodingHeterogenousArray() throws {
    let drinksJson = """
        [
            {"type": "drink", "description": "All natural"},
            {"type": "soda", "description": "best drunk on fridays after work", "sugar_content": "5%"}
        ]
        """.data(using: .utf8)!

    let drinks = try JSONDecoder().decodeHeterogeneousArray(OfFamily: DrinkFamily.self, from: drinksJson)

    XCTAssertEqual(drinks.count, 2)
    XCTAssertNotNil(drinks[1] as? Soda)
    XCTAssertEqual((drinks[1] as! Soda).sugar_content, "5%")
  }

  static var allTests = [
    ("testDecodingObjectWithHeterogenousJson", testDecodingObjectWithHeterogenousJson),
    ("testDecodingUnavailableTypeInHeterogenousJson", testDecodingUnavailableTypeInHeterogenousJson),
    ("testDecodingHeterogenousArray", testDecodingHeterogenousArray),
  ]
}
