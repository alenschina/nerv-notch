// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NervNotchPro",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "NervNotchPro", targets: ["NervNotchProApp"])
    ],
    targets: [
        .executableTarget(
            name: "NervNotchProApp",
            path: "Sources/NervNotchProApp"
        ),
        .testTarget(
            name: "NervNotchProTests",
            dependencies: ["NervNotchProApp"],
            path: "Tests/NervNotchProTests"
        )
    ]
)
