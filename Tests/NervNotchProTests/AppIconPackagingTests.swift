import XCTest

final class AppIconPackagingTests: XCTestCase {
    func testPackageScriptEmbedsAppIconIcnsInBundleInfo() throws {
        let projectRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let iconFile = projectRoot
            .appendingPathComponent("Sources/NervNotchProApp/Resources/NervNotch.icns")
        let packageScriptFile = projectRoot.appendingPathComponent("scripts/package-app.sh")
        let packageScript = try String(contentsOf: packageScriptFile)
        let iconAttributes = try FileManager.default.attributesOfItem(atPath: iconFile.path)
        let iconFileSize = try XCTUnwrap(iconAttributes[.size] as? NSNumber).intValue

        XCTAssertTrue(FileManager.default.fileExists(atPath: iconFile.path))
        XCTAssertGreaterThan(iconFileSize, 100_000)
        XCTAssertTrue(packageScript.contains(#"APP_ICON_PATH="$REPO_ROOT/Sources/NervNotchProApp/Resources/NervNotch.icns""#))
        XCTAssertTrue(packageScript.contains(#"cp "$APP_ICON_PATH" "$RESOURCES_DIR/NervNotch.icns""#))
        XCTAssertTrue(packageScript.contains("<key>CFBundleIconFile</key>"))
        XCTAssertTrue(packageScript.contains("<string>NervNotch</string>"))
    }
}
