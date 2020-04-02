// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "SwiftSimctl",
    platforms: [
        .iOS(.v11),
        .tvOS(.v11),
        .macOS(.v10_12)
    ],
    products: [
        .executable(name: "SimctlCLI", targets: ["SimctlCLI"]),
        .library(name: "Simctl", targets: ["Simctl"])
    ],
    dependencies: [
        .package(name: "ShellOut", url: "https://github.com/JohnSundell/ShellOut.git", from: "2.3.0"),
        .package(name: "Swifter",  url: "https://github.com/httpswift/swifter.git", from: "1.4.7")
    ],
    targets: [
        .target(name: "SimctlShared"),
        .target(name: "SimctlCLI", dependencies: ["SimctlShared", "ShellOut", "Swifter"]),
        .target(name: "Simctl", dependencies: ["SimctlShared"])
    ],
    swiftLanguageVersions: [.v5]
)
