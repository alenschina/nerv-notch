// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NervNotch",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "NervNotch", targets: ["NervNotchProApp"])
    ],
    targets: [
        .executableTarget(
            name: "NervNotchProApp",
            path: "Sources/NervNotchProApp",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "NervNotchProTests",
            dependencies: ["NervNotchProApp"],
            path: "Tests/NervNotchProTests"
        )
    ]
)
