import XCTest
@testable import libapi

final class libapiTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(libapi().text, "Hello, World!")
    }
}
