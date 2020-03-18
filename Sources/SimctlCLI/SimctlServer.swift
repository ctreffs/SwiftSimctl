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

class SimctlServer {
    let log: Logger
    let server: HttpServer

    init() {
        self.log = Logger(label: "com.simclt.server")
        server = HttpServer()
    }

    func startServer(on port: SimctlShared.Port) {
        do {
            try server.start(port)
            log.info("Server listening on port \(port)...")
            RunLoop.main.run()
        } catch {
            fatalError("Unable to start server on port \(port)")
        }
    }

    func stop() {
        server.stop()
    }

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
}
