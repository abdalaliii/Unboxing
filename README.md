# Unboxing

An extension for `KeyedDecodingContainer` class to decode a collection of heterogeneous types.

### Usage

Start by creating an enum that has variants for the parsable type it must adhere to ClassFamily. it also should define the type information `discriminator`.

```swift
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
```

Later in your collection overload the init method to use our `KeyedDecodingContainer` extension.

```swift
required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    drinks = try container.decode([Drink].self, ofFamily: DrinkFamily.self, forKey: .drinks)
}
```

### Installation

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/a6delali/Unboxing.git")
]
```

## Author

Abdel Ali, a6delalii@gmail.com

## License

Sorter is available under the MIT license. See the LICENSE file for more info.
