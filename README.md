# Unboxing

An extension for `KeyedDecodingContainer` class to decode a collection of heterogeneous types.

### Usage

Start by creating an enum that has variants for the parsable type it must adhere to ClassFamily and define the type information `discriminator`.

```swift
enum DrinkFamily: String, ClassFamily {
    case drink = "drink"
    case beer = "beer"

    static var discriminator: Discriminator = .type
    
    typealias BaseType = Drink

    func getType() -> Drink.Type {
        switch self {
        case .beer:
            return Beer.self
        case .drink:
            return Drink.self
        }
    }
}
```

Later in your collection overload the init method to use our `KeyedDecodingContainer` extension.

```swift
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
```

Otherwise follow the below example to decode an Hetegerenous json array object.

```swift
let drinksJson = """
[
    {"type": "drink", "description": "All natural"},
    {"type": "beer", "description": "best drunk on fridays after work", "alcohol_content": "5%"}
]
""".data(using: .utf8)!

let drinks = try JSONDecoder().decodeHeterogeneousArray(OfFamily: DrinkFamily.self, from: drinksJson)
```

### Update

I've added the possibility to decode and flatten JSON with dynamic keys. Let's consider the following snippet:

```json
{
  "1": {
    "name": "john"
  },
  "2": {
    "name": "smith"
  }
}
```
To extract the data from the above json, all you have to do is define your model and ask the JSONDecode to use `DecodedArray` new type.

```swift
struct Person: Decodable {
  let name: String
}

let _ = try JSONDecoder().decode(DecodedArray<Person>.self, from: barJson)
```

### Installation

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/abdalaliii/Unboxing.git")
]
```

## License

**Unboxing** is available under the MIT license. See the LICENSE file for more info.
