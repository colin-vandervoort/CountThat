// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "CountThatTools",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.0")
    ]
)
