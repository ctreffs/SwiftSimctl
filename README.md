# Swift Simctl

[![license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![swift version](https://img.shields.io/badge/swift-5.2-brightgreen.svg)](https://swift.org/download)
[![platforms](https://img.shields.io/badge/platforms-%20macOS%20|%20iOS%20|%20tvOS-brightgreen.svg)](#)

<p align="center">
	<img src="docs/SimctlExample.gif" height="300" alt="simctl-example-gif"/>
</p>   


This is a small tool (SimctlCLI) and library (Simctl) written in Swift to automate [`xcrun simctl`](https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/iOS_Simulator_Guide/InteractingwiththeiOSSimulator/InteractingwiththeiOSSimulator.html#//apple_ref/doc/uid/TP40012848-CH3-SW4) commands for Simulator in unit and UI tests.

It enables reliable, **fully automated** testing of Push Notifications with dynamic content and driven by a UI Test you control.

<p align="center">
<img src="docs/Overview.png" height="400"/>
</p>

## 🚀 Getting Started

These instructions will get your copy of the project up and running on your machine.

### 📋 Prerequisites

- [Xcode 11.4](https://developer.apple.com/documentation/xcode_release_notes/) and higher.
- [Swift Package Manager (SPM)](https://github.com/apple/swift-package-manager)
- [Swiftlint](https://github.com/realm/SwiftLint) for linting - (optional)
- [SwiftEnv](https://swiftenv.fuller.li/) for Swift version management - (optional)

### 💻 Installing

#### Using the library

To use Swift Simctl in your code add the package to your project.

In Xcode:

1. File > Swift Packages > Add Package Dependency...
2. Choose Package Repository > Search: `SwiftSimctl` or find `https://github.com/ctreffs/SwiftSimctl.git`
3. Select  `SwiftSimctl` package > `Next`

![xcode-swift-package](docs/XcodeSwiftPackage.png)

#### Setup server


## 🎌 Pros & Cons

#### ➕ Pro
- Enclosed system (Mac with Xcode + Simulator)
- No external dependencies to systems like [APNS](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html)
- No custom testing code, bloating your code base necessary

#### ➖ Contra
- Needs a little configuration in your Xcode project

## ✍️ Authors

* [Christian Treffs](https://github.com/ctreffs)

See also the list of [contributors](https://github.com/ctreffs/SwiftImGui/contributors) who participated in this project.

## 🔏 Licenses

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
