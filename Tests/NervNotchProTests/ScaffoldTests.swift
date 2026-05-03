import XCTest
@testable import NervNotchProApp

final class ScaffoldTests: XCTestCase {
    func testApplicationWrapperCanBeCreated() {
        let application = NervNotchApplication()
        XCTAssertNotNil(application)
    }
}
