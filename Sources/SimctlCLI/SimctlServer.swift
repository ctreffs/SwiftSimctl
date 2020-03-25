//
//  File.swift
//
//
//  Created by Christian Treffs on 18.03.20.
//

import ArgumentParser
import Foundation
import Logging
import ShellOut
import SimctlShared
import Swifter

/// The server used to receive commands from an app and
/// translate them into commands on the local machine.
final class SimctlServer {
    let log: Logger
    let server: HttpServer

    init() {
        self.log = Logger(label: "com.simclt.server")
        server = HttpServer()
    }

    /// Start a server that listens to library requests from your app and executes simctl commands on your machine.
    /// - Parameter port: the port on which to listen.
    func startServer(on port: SimctlShared.Port) {
        do {
            try server.start(port)
            log.info("Server listening on port \(port)...")
            RunLoop.main.run()
        } catch {
            fatalError("Unable to start server on port \(port)")
        }
    }

    /// Stop the server.
    func stop() {
        server.stop()
    }

    /// Callback to be executed on push notifcation send request.
    /// - Parameter closure: The closure to be executed.
    func onPushNotification(_ closure: @escaping (UUID, String?, PushNotificationContent) -> Result<String, Swift.Error>) {
        server.POST[ServerPath.pushNotification.rawValue] = { request in
            guard let deviceId = request.headerValue(for: .deviceUdid, UUID.init) else {
                return .badRequest(.text("Device Udid missing or corrupt."))
            }

            guard let bundleId = request.headerValue(for: .bundleIdentifier) else {
                return .badRequest(.text("Bundle Id missing or corrupt."))
            }

            let bodyData = Data(request.body)
            let decoder = JSONDecoder()
            do {
                let pushContent: PushNotificationContent = try decoder.decode(PushNotificationContent.self, from: bodyData)

                let result = closure(deviceId, bundleId, pushContent)

                switch result {
                case let .success(output):
                    return .ok(.text(output))

                case let .failure(error):
                    return .badRequest(.text(error.localizedDescription))
                }
            } catch {
                return .badRequest(.text(error.localizedDescription))
            }
        }
    }

    /// Callback to be executed on privacy change request.
    /// - Parameter closure: The closure to be executed.
    func onPrivacy(_ closure: @escaping (UUID, String?, PrivacyAction, PrivacyService) -> Result<String, Swift.Error>) {
        server.GET[ServerPath.privacy.rawValue] = { request in
            guard let deviceId = request.headerValue(for: .deviceUdid, UUID.init) else {
                return .badRequest(.text("Device Udid missing or corrupt."))
            }

            guard let bundleId = request.headerValue(for: .bundleIdentifier) else {
                return .badRequest(.text("Bundle Id missing or corrupt."))
            }

            guard let action: PrivacyAction = request.headerValue(for: .privacyAction) else {
                return .badRequest(.text("Privacy action missing or corrupt."))
            }

            guard let service: PrivacyService = request.headerValue(for: .privacyService) else {
                return .badRequest(.text("Privacy service missing or corrupt."))
            }

            let result = closure(deviceId, bundleId, action, service)

            switch result {
            case let .success(output):
                return .ok(.text(output))

            case let .failure(error):
                return .badRequest(.text(error.localizedDescription))
            }
        }
    }

    /// Callback to be executed on rename device request.
    /// - Parameter closure: The closure to be executed.
    func onRename(_ closure: @escaping (UUID, String?, String) -> Result<String, Swift.Error>) {
        server.GET[ServerPath.renameDevice.rawValue] = { request in
            guard let deviceId = request.headerValue(for: .deviceUdid, UUID.init) else {
                return .badRequest(.text("Device Udid missing or corrupt."))
            }

            guard let bundleId = request.headerValue(for: .bundleIdentifier) else {
                return .badRequest(.text("Bundle Id missing or corrupt."))
            }

            guard let deviceName: String = request.headerValue(for: .deviceName) else {
                return .badRequest(.text("No device name parameter provided."))
            }

            let result = closure(deviceId, bundleId, deviceName)

            switch result {
            case let .success(output):
                return .ok(.text(output))

            case let .failure(error):
                return .badRequest(.text(error.localizedDescription))
            }
        }
    }

    /// Callback to be executed on terminate app device request.
    /// - Parameter closure: The closure to be executed.
    func onTerminateApp(_ closure: @escaping (UUID, String?, String) -> Result<String, Swift.Error>) {
        server.GET[ServerPath.terminateApp.rawValue] = { request in
            guard let deviceId = request.headerValue(for: .deviceUdid, UUID.init) else {
                return .badRequest(.text("Device Udid missing or corrupt."))
            }

            guard let bundleId = request.headerValue(for: .bundleIdentifier) else {
                return .badRequest(.text("Bundle Id missing or corrupt."))
            }

            guard let targetAppBundleId: String = request.headerValue(for: .targetBundleIdentifier) else {
                return .badRequest(.text("No target app bundle id parameter provided."))
            }

            let result = closure(deviceId, bundleId, targetAppBundleId)

            switch result {
            case let .success(output):
                return .ok(.text(output))

            case let .failure(error):
                return .badRequest(.text(error.localizedDescription))
            }
        }
    }

    func onSetDeviceAppearance(_ closure: @escaping (UUID, String?, DeviceAppearance) -> Result<String, Swift.Error>) {
        server.GET[ServerPath.deviceAppearance.rawValue] = { request in
            guard let deviceId = request.headerValue(for: .deviceUdid, UUID.init) else {
                return .badRequest(.text("Device Udid missing or corrupt."))
            }

            guard let bundleId = request.headerValue(for: .bundleIdentifier) else {
                return .badRequest(.text("Bundle Id missing or corrupt."))
            }

            guard let appearance: DeviceAppearance = request.headerValue(for: .deviceAppearance) else {
                return .badRequest(.text("Device appearance missing or corrupt."))
            }

            let result = closure(deviceId, bundleId, appearance)

            switch result {
            case let .success(output):
                return .ok(.text(output))

            case let .failure(error):
                return .badRequest(.text(error.localizedDescription))
            }
        }
    }

    func onTriggerICloudSync(_ closure: @escaping (UUID, String?) -> Result<String, Swift.Error>) {
        server.GET[ServerPath.iCloudSync.rawValue] = { request in
            guard let deviceId = request.headerValue(for: .deviceUdid, UUID.init) else {
                return .badRequest(.text("Device Udid missing or corrupt."))
            }

            guard let bundleId = request.headerValue(for: .bundleIdentifier) else {
                return .badRequest(.text("Bundle Id missing or corrupt."))
            }

            let result = closure(deviceId, bundleId)

            switch result {
            case let .success(output):
                return .ok(.text(output))

            case let .failure(error):
                return .badRequest(.text(error.localizedDescription))
            }
        }
    }

    /// Callback to be executed on uninstall app device request.
    /// - Parameter closure: The closure to be executed.
    func onUninstallApp(_ closure: @escaping (UUID, String?, String) -> Result<String, Swift.Error>) {
        server.GET[ServerPath.uninstallApp.rawValue] = { request in
            guard let deviceId = request.headerValue(for: .deviceUdid, UUID.init) else {
                return .badRequest(.text("Device Udid missing or corrupt."))
            }

            guard let bundleId = request.headerValue(for: .bundleIdentifier) else {
                return .badRequest(.text("Bundle Id missing or corrupt."))
            }

            guard let targetAppBundleId: String = request.headerValue(for: .targetBundleIdentifier) else {
                return .badRequest(.text("No target app bundle id parameter provided."))
            }

            let result = closure(deviceId, bundleId, targetAppBundleId)

            switch result {
            case let .success(output):
                return .ok(.text(output))

            case let .failure(error):
                return .badRequest(.text(error.localizedDescription))
            }
        }
    }

    /// Callback to be executed on set status bar override request.
    /// - Parameter closure: The closure to be executed.
    func onSetStatusBarOverride(_ closure: @escaping (UUID, String?, Set<StatusBarOverride>) -> Result<String, Swift.Error>) {
        server.POST[ServerPath.statusBarOverrides.rawValue] = { request in
            guard let deviceId = request.headerValue(for: .deviceUdid, UUID.init) else {
                return .badRequest(.text("Device Udid missing or corrupt."))
            }

            guard let bundleId = request.headerValue(for: .bundleIdentifier) else {
                return .badRequest(.text("Bundle Id missing or corrupt."))
            }

            let bodyData = Data(request.body)
            let decoder = JSONDecoder()
            do {
                let overrides: Set<StatusBarOverride> = try decoder.decode(Set<StatusBarOverride>.self, from: bodyData)

                let result = closure(deviceId, bundleId, overrides)

                switch result {
                case let .success(output):
                    return .ok(.text(output))

                case let .failure(error):
                    return .badRequest(.text(error.localizedDescription))
                }
            } catch {
                return .badRequest(.text(error.localizedDescription))
            }
        }
    }
}
