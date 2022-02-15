//
//  StartServer.swift
//
//
//  Created by Christian Treffs on 18.03.20.
//

import ArgumentParser
import Foundation
import ShellOut
import SimctlShared
import Swifter

struct StartServer: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Start the server that will be called by your test code to run the commands")

    @Option(name: .shortAndLong, help: "The port to listen on")
    var port: SimctlShared.Port = Port(8080)

    @Flag(name: .shortAndLong, help: "Show the commands received and the responses sent")
    var verbose = false

    mutating func run() throws {
        let server = SimctlServer()
        let v = verbose

        server.onPushNotification { deviceId, bundleId, pushContent -> Result<String, Swift.Error> in
            runCommand(.simctlPush(to: deviceId, pushContent: pushContent, bundleIdentifier: bundleId), verbose: v)
        }

        server.onPrivacy { deviceId, bundleId, action, service -> Result<String, Swift.Error> in
            runCommand(.simctlPrivacy(action, permissionsFor: service, on: deviceId, bundleIdentifier: bundleId), verbose: v)
        }

        server.onRename { deviceId, _, newName -> Result<String, Swift.Error> in
            runCommand(.simctlRename(device: deviceId, to: newName), verbose: v)
        }

        server.onTerminateApp { deviceId, _, appBundleId -> Result<String, Swift.Error> in
            runCommand( .simctlTerminateApp(device: deviceId, appBundleIdentifier: appBundleId), verbose: v)
        }

        server.onErase { deviceId -> Result<String, Swift.Error> in
            runCommand( .simctlErase(device: deviceId), verbose: v)
        }

        server.onSetDeviceAppearance { deviceId, _, appearance -> Result<String, Swift.Error> in
            runCommand(.simctlSetUI(appearance: appearance, on: deviceId), verbose: v)
        }

        server.onTriggerICloudSync { deviceId, _ -> Result<String, Swift.Error> in
            runCommand(.simctlTriggerICloudSync(device: deviceId), verbose: v)
        }

        server.onUninstallApp { deviceId, _, appBundleId -> Result<String, Swift.Error> in
            runCommand(.simctlUninstallApp(device: deviceId, appBundleIdentifier: appBundleId), verbose: v)
        }

        server.onSetStatusBarOverride { deviceId, _, overrides -> Result<String, Swift.Error> in
            runCommand(.simctlSetStatusBarOverrides(device: deviceId, overrides: overrides), verbose: v)
        }

        server.onClearStatusBarOverrides { deviceId, _ -> Result<String, Swift.Error> in
            runCommand(.simctlClearStatusBarOverrides(device: deviceId), verbose: v)
        }

        server.onOpenUrl { deviceId, _, url -> Result<String, Swift.Error> in
            runCommand(.simctlOpen(url: url, on: deviceId))
        }

        server.onGetAppContainer { deviceId, appBundleId, container -> Result<String, Swift.Error> in
            runCommand(.simctlGetAppContainer(device: deviceId, appBundleIdentifier: appBundleId, container: container))
        }

        server.startServer(on: port)
    }
}

private func runCommand(_ cmd: ShellOutCommand, verbose: Bool = false) -> Result<String, Swift.Error> {
    if verbose {
        print("Command: \(cmd.string)")
    }
    do {
        let output: String = try shellOut(to: cmd)
        if verbose {
            print("Success: \(output)")
        }
        return .success(output)
    } catch {
        if verbose {
            print("Failure: \(error)")
        }
        return .failure(error)
    }
}
