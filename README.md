# Swift Simctl

[![build](https://github.com/ctreffs/SwiftSimctl/workflows/Swift-macOS/badge.svg)](actions)
[![license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)
[![swift version](https://img.shields.io/badge/swift-5.2-brightgreen.svg)](https://swift.org/download)
[![platforms](https://img.shields.io/badge/platforms-%20macOS%20|%20iOS%20|%20tvOS-brightgreen.svg)](#)

<p align="center">
	<img src="docs/SimctlExample.gif" height="300" alt="simctl-example-gif"/>
</p>   


This is a small tool (SimctlCLI) and library (Simctl), written in Swift, to automate [`xcrun simctl`](https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/iOS_Simulator_Guide/InteractingwiththeiOSSimulator/InteractingwiththeiOSSimulator.html#//apple_ref/doc/uid/TP40012848-CH3-SW4) commands for Simulator in unit and UI tests.

It enables, among other things, reliable **fully automated** testing of Push Notifications with dynamic content, and driven by a UI Test you control.

### 🚧 Architecture

<p align="center">
	<a href="docs/Overview.png" target="_blank"><img src="docs/Overview.png" height="500"/></a>
</p>

Swift Simctl is made of two parts. `SimctlCLI` and `Simctl`.

`Simctl` is a Swift library that can be added to your project's test bundles. 
It provides an interface to commands that are otherwise only available via `xcrun simctl` from within your test code.
To enable calling these commands `Simctl` communicates over a local network connection to `SimctlCLI`.

`SimctlCLI` is a small command line tool that starts a local server, listens to requrests from `Simctl` (the client library) and executes `xcrun simctl` commands.

### ⌨ Available Commands

The following commands will be available in code in your (test) targets:

- Send push notifications with custom payload
- Grant or revoke privacy permissions
- Set the device UI appearance to light or dark mode
- Set status bar overrides i.e. data network or time
- Uninstall app by bundle id
- Terminate app by bundle id
- Rename device
- Trigger iCloud Sync

## ❔ Why would you (not) use this

#### ➕ Pro

- Closed system (Mac with Xcode + Simulator)
- No external dependencies on systems like [APNS](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html)
- No custom test code bloating your code base unnecessarily
- Push notifications can be simulated properly and the normal app cycle is preserved
- Runs on CI machines
- Your app stays a black box and does not need to be modified

#### ➖ Contra

- Needs a little configuration in your Xcode project
- Only available for Xcode 11.4+ and Swift 5.2+

For specific usage please refer to the example project **<https://github.com/ctreffs/SwiftSimctlExample>**

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

#### Setting up the server

Ensure that for the duration of your test run `SimctlCLI` runs on your host machine.

To automate that with Xcode itself use the following snipets as pre and post action of your test target.

###### Test > Pre-Actions > Run Script

```sh
#!/bin/bash

# cleaning up hanging servers
killall SimctlCLI 

# fail fast
set -e

# start the server non-blocking from the checked out package
${BUILD_ROOT}/../../SourcePackages/checkouts/SwiftSimctl/bin/SimctlCLI start-server > /dev/null 2>&1 &
```

###### Test > Post-Actions > Run Script

```sh
#!/bin/bash

set -e

killall SimctlCLI

```

### 📝 Code Example

Please refer to the example project for an in depth code example.

**<https://github.com/ctreffs/SwiftSimctlExample>**

## 🙏 Kudos

`Simctl` would not be possible without these awesome packages:

- [ShellOut](https://github.com/JohnSundell/ShellOut) - easy command line invocations
- [Swifter](https://github.com/httpswift/swifter) - a tiny http server
- [Swift Log](https://github.com/apple/swift-log) - Apple's logger lib
- [Swift Argument Parser](https://github.com/apple/swift-argument-parser) - Apple's command line argument parsing lib


## ✍️ Authors

* [Christian Treffs](https://github.com/ctreffs)

See also the list of [contributors](contributors) who participated in this project.

## 🔏 Licenses

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
