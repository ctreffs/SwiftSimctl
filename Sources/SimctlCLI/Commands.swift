//
//  Commands.swift
//
//
//  Created by Christian Treffs on 17.03.20.
//

import Foundation
import ShellOut
import SimctlShared

extension ShellOutCommand {
    static func openSimulator() -> ShellOutCommand {
        .init(string: "open -b com.apple.iphonesimulator")
    }

    static func killAllSimulators() -> ShellOutCommand {
        .init(string: "killall Simulator")
    }

    private static func simctl(_ cmd: String) -> String {
        "xcrun simctl \(cmd)"
    }

    /// Usage: simctl list [-j | --json] [-v] [devices|devicetypes|runtimes|pairs] [<search term>|available]
    static func simctlList(_ filter: ListFilterType = .noFilter, _ asJson: Bool = false, _ verbose: Bool = false) -> ShellOutCommand {
        let cmd: String = [
            "list",
            "\(asJson ? "--json" : "")",
            "\(verbose ? "-v" : "")",
            filter.rawValue
        ].joined(separator: " ")
        return .init(string: simctl(cmd))
    }

    static func simctlBoot(device: UUID) -> ShellOutCommand {
        .init(string: simctl("boot \(device.uuidString)"))
    }

    static func simctlShutdown(device: UUID) -> ShellOutCommand {
        .init(string: simctl("shutdown \(device.uuidString)"))
    }

    static func simctlShutdownAllDevices() -> ShellOutCommand {
        .init(string: simctl("shutdown all"))
    }

    static func simctlOpen(url: URL, on device: UUID) -> ShellOutCommand {
        .init(string: simctl("openurl \(device.uuidString) \(url.absoluteString)"))
    }

    /// Usage: simctl ui <device> <option> [<arguments>]
    static func simctlSetUI(apperance: DeviceApperance, on device: UUID) -> ShellOutCommand {
        .init(string: simctl("ui \(device.uuidString) appearance \(apperance.rawValue)"))
    }

    /// xcrun simctl push <device> com.example.my-app ExamplePush.apns
    /// simctl push <device> [<bundle identifier>] (<json file> | -)
    static func simctlPush(to device: UUID, pushContent: PushNotificationContent, bundleIdentifier: String? = nil) -> ShellOutCommand {
        switch pushContent {
        case let .file(url):
            return .init(string: simctl("push \(device.uuidString) \(bundleIdentifier ?? "") \(url.path)"))

        case let .jsonPayload(data):
            var jsonString = String(data: data, encoding: .utf8) ?? ""
            jsonString = jsonString.replacingOccurrences(of: "\n", with: "")
            return .init(string: simctl("push \(device.uuidString) \(bundleIdentifier ?? "") - <<< '\(jsonString)'"))
        }
    }

    ///  simctl privacy <device> <action> <service> [<bundle identifier>]
    static func simctlPrivacy(_ action: PrivacyAction, permissionsFor service: PrivacyService, on device: UUID, bundleIdentifier: String?) -> ShellOutCommand {
        .init(string: simctl("privacy \(device.uuidString) \(action.rawValue) \(service.rawValue) \(bundleIdentifier ?? "")"))
    }

    /// Rename a device.
    ///
    /// Usage: simctl rename <device> <name>
    ///
    /// - Parameters:
    ///   - device: The device Udid
    ///   - name: The new name
    static func simctlRename(device: UUID, to name: String) -> ShellOutCommand {
        .init(string: simctl("rename \(device.uuidString) \(name)"))
    }
}

enum ListFilterType: String {
    case devices
    case devicetypes
    case runtimes
    case pairs
    case noFilter = ""
}

enum DeviceApperance: String {
    case light
    case dark
}
