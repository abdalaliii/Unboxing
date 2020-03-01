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
        drinks = try container.decode([Drink].self, ofFamily: DrinkFamily.self, forKey: .drinks)
    }
}

enum DrinkFamily: String, ClassFamily {
    case drink = "drink"
    case beer = "beer"

    static var discriminator: Discriminator = .type

    func getType() -> AnyObject.Type {
        switch self {
        case .beer:
            return Beer.self
        case .drink:
            return Drink.self
        }
    }
}


final class UnboxingTests: XCTestCase {

    let heterogenousJson = """
    {
        "drinks": [
            {
                "type": "drink",
                "description": "All natural"
            },
            {
                "type": "beer",
                "description": "best drunk on fridays after work",
                "alcohol_content": "5%"
            }
        ]
    }
    """.data(using: .utf8)!

    func testDecodingHeterogenousJson() throws {
        let bar = try JSONDecoder().decode(Bar.self, from: heterogenousJson)

        XCTAssertTrue(bar.drinks.count > 0)
        XCTAssertEqual(bar.drinks[0].description, "All natural")
        XCTAssertNotNil(bar.drinks[1] as? Beer)
        XCTAssertEqual((bar.drinks[1] as! Beer).description, "best drunk on fridays after work")
    }

    static var allTests = [
        ("testDecodingHeterogenousJson", testDecodingHeterogenousJson),
    ]
}
