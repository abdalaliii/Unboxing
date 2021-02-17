import XCTest
@testable import Unboxing

class Drink: Decodable {
  let type: String
  let description: String
}

class Beer: Drink {
  var alcohol_content: String
  
  private enum CodingKeys: String, CodingKey {
    case alcohol_content
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.alcohol_content = try container.decode(String.self, forKey: .alcohol_content)
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
  case beer = "beer"
  
  static var discriminator: Discriminator = .type
  
  func getType() -> Drink.Type {
    switch self {
      case .beer:
        return Beer.self
      case .drink:
        return Drink.self
    }
  }
}


final class UnboxingTests: XCTestCase {
  
  func testDecodingObjectWithHeterogenousJson() throws {
    let barJson = """
        {
            "drinks":
            [
                {"type": "drink", "description": "All natural"},
                {"type": "beer", "description": "best drunk on fridays after work", "alcohol_content": "5%"}
            ]
        }
        """.data(using: .utf8)!
    
    let bar = try JSONDecoder().decode(Bar.self, from: barJson)
    
    XCTAssertTrue(bar.drinks.count > 0)
    XCTAssertEqual(bar.drinks[0].description, "All natural")
    XCTAssertNotNil(bar.drinks[1] as? Beer)
    XCTAssertEqual((bar.drinks[1] as! Beer).description, "best drunk on fridays after work")
  }
  
  func testDecodingHeterogenousArray() throws {
    let drinksJson = """
        [
            {"type": "drink", "description": "All natural"},
            {"type": "beer", "description": "best drunk on fridays after work", "alcohol_content": "5%"}
        ]
        """.data(using: .utf8)!
    
    let drinks = try JSONDecoder().decodeHeterogeneousArray(OfFamily: DrinkFamily.self, from: drinksJson)
    
    XCTAssertTrue(drinks.count > 0)
    XCTAssertEqual(drinks[0].description, "All natural")
    XCTAssertNotNil(drinks[1] as? Beer)
    XCTAssertEqual((drinks[1] as! Beer).description, "best drunk on fridays after work")
  }
  
  static var allTests = [
    ("testDecodingObjectWithHeterogenousJson", testDecodingObjectWithHeterogenousJson),
    ("testDecodingHeterogenousArray", testDecodingHeterogenousArray),
  ]
}
