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
    static func simctlSetUI(appearance: DeviceAppearance, on device: UUID) -> ShellOutCommand {
        .init(string: simctl("ui \(device.uuidString) appearance \(appearance.rawValue)"))
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

    /// Terminate an application by identifier on a device.
    ///
    /// Usage: simctl terminate <device> <app bundle identifier>
    ///
    /// - Parameters:
    ///   - device: The device Udid
    ///   - appBundleIdentifier: App bundle identifier of the app to terminate.
    static func simctlTerminateApp(device: UUID, appBundleIdentifier: String) -> ShellOutCommand {
        .init(string: simctl("terminate \(device.uuidString) \(appBundleIdentifier)"))
    }
    
    static func simctlErase(device: UUID) -> ShellOutCommand {
        .init(string: simctl("erase \(device.uuidString)"))
    }

    /// Trigger iCloud sync on a device.
    ///
    /// Usage: simctl icloud_sync <device>
    ///
    /// - Parameter device: The device Udid
    static func simctlTriggerICloudSync(device: UUID) -> ShellOutCommand {
        .init(string: simctl("icloud_sync \(device.uuidString)"))
    }

    /// Uninstall an app from a device.
    ///
    /// Usage: simctl uninstall <device> <app bundle identifier>
    ///
    /// - Parameters:
    ///   - device: The device Udid
    ///   - appBundleIdentifier: App bundle identifier of the app to uninstall.
    static func simctlUninstallApp(device: UUID, appBundleIdentifier: String) -> ShellOutCommand {
        .init(string: simctl("uninstall \(device.uuidString) \(appBundleIdentifier)"))
    }

    /// Clear status bar overrides
    ///
    /// Usage: simctl status_bar <device> clear
    /// - Parameter device: The device Udid
    static func simctlClearStatusBarOverrides(device: UUID) -> ShellOutCommand {
        .init(string: simctl("status_bar \(device.uuidString) clear"))
    }

    /// Set status bar overrides
    ///
    /// Usage: simctl status_bar <device> override <override arguments>
    /// - Parameters:
    ///   - device: The device Udid
    ///   - overrides: A set of overrides to set.
    static func simctlSetStatusBarOverrides(device: UUID, overrides: Set<StatusBarOverride>) -> ShellOutCommand {
        .init(string: simctl("status_bar \(device.uuidString) override \(overrides.map { $0.command }.joined(separator: " "))"))
    }
}

internal enum ListFilterType: String {
    case devices
    case devicetypes
    case runtimes
    case pairs
    case noFilter = ""
}
