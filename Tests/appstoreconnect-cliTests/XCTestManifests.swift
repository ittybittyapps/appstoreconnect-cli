import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(appstoreconnect_cliTests.allTests),
    ]
}
#endif
