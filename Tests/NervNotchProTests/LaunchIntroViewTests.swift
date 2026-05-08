import XCTest
@testable import NervNotchProApp

final class LaunchIntroViewTests: XCTestCase {
    func testLaunchIntroUsesApostleWarningTextAndSourceHanSerifFont() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceFile = projectRoot
            .appendingPathComponent("Sources/NervNotchProApp/UI/LaunchIntroView.swift")
        let source = try String(contentsOf: sourceFile)

        XCTAssertTrue(source.contains("Text(\"使徒來襲\")"))
        XCTAssertTrue(source.contains(#".font(.custom(LaunchIntroTypography.fontName, size: 18))"#))
        XCTAssertTrue(source.contains(#".font(.custom(LaunchIntroTypography.fontName, size: 96))"#))
        XCTAssertFalse(source.contains(".font(.system"))
        XCTAssertFalse(source.contains("Text(\"使徒来袭\")"))
        XCTAssertFalse(source.contains("Text(\"机密\")"))
    }
}
