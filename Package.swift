// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SwiftSimctl",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_11)
    ],
    products: [
        .executable(
            name: "SimctlCLI",
            targets: ["SimctlCLI"]),
        .library(name: "Simctl",
                 type: .static,
                 targets: ["Simctl"])
    ],
    dependencies: [
        .package(url: "https://github.com/httpswift/swifter.git", from: "1.4.7"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.0.2"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.3.0")
    ],
    targets: [
        .target(name: "SimctlShared"),
        .target(
            name: "SimctlCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Swifter"),
                .product(name: "Logging"),
                .product(name: "ShellOut"),
                .byName(name: "SimctlShared")
        ]),
        .target(name: "Simctl",
                dependencies: ["Logging",
                               "SimctlShared"]),
        .testTarget(name: "SimctlTests",
                    dependencies: ["Simctl"])
        
    ]
)
