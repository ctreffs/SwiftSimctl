// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "SwiftSimctl",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
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
        .package(name: "swift-log", url: "https://github.com/apple/swift-log.git", from: "1.2.0"),
        .package(name: "Swifter", url: "https://github.com/httpswift/swifter.git", from: "1.4.7"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.0.2"),
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.3.0")
    ],
    targets: [
        .target(name: "SimctlShared"),
        .target(
            name: "SimctlCLI",
            dependencies: [
                .byName(name: "ShellOut"),
                .byName(name: "SimctlShared"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Swifter", package: "Swifter")
        ]),
        .target(name: "Simctl",
                dependencies: [
                    .byName(name: "SimctlShared"),
                    .product(name: "Logging", package: "swift-log")
        ])
        
    ]
)
