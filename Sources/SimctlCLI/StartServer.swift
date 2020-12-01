//
//  SimctlCLI.swift
//
//
//  Created by Christian Treffs on 18.03.20.
//

import Foundation
import ShellOut
import SimctlShared
import Swifter
import ArgumentParser

struct StartServer: ParsableCommand {

    static var configuration = CommandConfiguration(abstract: "Start the server that will be called by your test code to run the commands")
    
    @Option(name: .shortAndLong, help: "The port to listen on")
    var port: SimctlShared.Port = Port(8080)
    
    mutating func run() throws {
        let server = SimctlServer()
        
        server.onPushNotification { deviceId, bundleId, pushContent -> Result<String, Swift.Error> in
            return runCommand(.simctlPush(to: deviceId, pushContent: pushContent, bundleIdentifier: bundleId))
        }

        server.onPrivacy { deviceId, bundleId, action, service -> Result<String, Swift.Error> in
            return runCommand(.simctlPrivacy(action, permissionsFor: service, on: deviceId, bundleIdentifier: bundleId))
        }

        server.onRename { deviceId, _, newName -> Result<String, Swift.Error> in
            return runCommand(.simctlRename(device: deviceId, to: newName))
        }

        server.onTerminateApp { deviceId, _, appBundleId -> Result<String, Swift.Error> in
            return runCommand( .simctlTerminateApp(device: deviceId, appBundleIdentifier: appBundleId))
        }

        server.onSetDeviceAppearance { deviceId, _, appearance -> Result<String, Swift.Error> in
            return runCommand(.simctlSetUI(appearance: appearance, on: deviceId))
        }

        server.onTriggerICloudSync { deviceId, _ -> Result<String, Swift.Error> in
            return runCommand(.simctlTriggerICloudSync(device: deviceId))
        }

        server.onUninstallApp { deviceId, _, appBundleId -> Result<String, Swift.Error> in
            return runCommand(.simctlUninstallApp(device: deviceId, appBundleIdentifier: appBundleId))
        }

        server.onSetStatusBarOverride { deviceId, _, overrides -> Result<String, Swift.Error> in
            return runCommand(.simctlSetStatusBarOverrides(device: deviceId, overrides: overrides))
        }

        server.onClearStatusBarOverrides { deviceId, _ -> Result<String, Swift.Error> in
            return runCommand(.simctlClearStatusBarOverrides(device: deviceId))
        }
        
        server.startServer(on: port)
    }
    
}

private func runCommand(_ cmd: ShellOutCommand) -> Result<String, Swift.Error> {
    do {
        let output: String = try shellOut(to: cmd)
        return .success(output)
    } catch {
        return .failure(error)
    }
}
