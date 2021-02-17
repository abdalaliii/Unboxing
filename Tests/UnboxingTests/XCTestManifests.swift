import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
  return [
    testCase(UnboxingTests.allTests),
    testCase(DecodedArrayTests.allTests),
  ]
}
#endif
