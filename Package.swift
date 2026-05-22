// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SnipHalo",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "SnipHalo",
            path: "Sources/SnipHalo"
        )
    ]
)
