// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "QuickSmiley",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "QuickSmiley",
            path: "Sources/QuickSmiley"
        )
    ]
)
