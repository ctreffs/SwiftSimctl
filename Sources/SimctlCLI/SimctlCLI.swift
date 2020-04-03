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

/// **SimctlCLI**
///
/// A command line interface to run a server accepting remote commands from your app to execute locally.
///
public class SimctlCLI {
    public enum Error: Swift.Error {
        case dataConversionFailed
    }

    let server: SimctlServer

    static let instance = SimctlCLI()

    public init() {
        server = SimctlServer()

        setupServerCallbacks()
    }

    deinit {
        server.stop()
    }

    func listDevices() -> [SimulatorDevice] {
        do {
            let devicesJSONString = try shellOut(to: .simctlList(.devices, true))
            guard let devicesData: Data = devicesJSONString.data(using: .utf8) else {
                throw Error.dataConversionFailed
            }
            let decoder = JSONDecoder()
            let listing = try decoder.decode(SimulatorDeviceListing.self, from: devicesData)
            return listing.devices
        } catch {
            return []
        }
    }

    func runCommand(_ cmd: ShellOutCommand) -> Result<String, Swift.Error> {
        do {
            let output: String = try shellOut(to: cmd)
            return .success(output)
        } catch {
            return .failure(error)
        }
    }
}

// MARK: - Server callbacks
extension SimctlCLI {
    func setupServerCallbacks() {
        server.onPushNotification { [unowned self] deviceId, bundleId, pushContent -> Result<String, Swift.Error> in
            let cmd: ShellOutCommand = .simctlPush(to: deviceId,
                                                   pushContent: pushContent,
                                                   bundleIdentifier: bundleId)

            return self.runCommand(cmd)
        }

        server.onPrivacy { [unowned self] deviceId, bundleId, action, service -> Result<String, Swift.Error> in
            let cmd: ShellOutCommand = .simctlPrivacy(action,
                                                      permissionsFor: service,
                                                      on: deviceId,
                                                      bundleIdentifier: bundleId)

            return self.runCommand(cmd)
        }

        server.onRename { [unowned self] deviceId, _, newName -> Result<String, Swift.Error> in
            let cmd: ShellOutCommand = .simctlRename(device: deviceId, to: newName)

            return self.runCommand(cmd)
        }

        server.onTerminateApp { [unowned self] deviceId, _, appBundleId -> Result<String, Swift.Error> in
            let cmd: ShellOutCommand = .simctlTerminateApp(device: deviceId, appBundleIdentifier: appBundleId)

            return self.runCommand(cmd)
        }

        server.onSetDeviceAppearance {[unowned self] deviceId, _, appearance -> Result<String, Swift.Error> in
            let cmd: ShellOutCommand = .simctlSetUI(appearance: appearance, on: deviceId)

            return self.runCommand(cmd)
        }

        server.onTriggerICloudSync { [unowned self] deviceId, _ -> Result<String, Swift.Error> in
            let cmd: ShellOutCommand = .simctlTriggerICloudSync(device: deviceId)

            return self.runCommand(cmd)
        }

        server.onUninstallApp { [unowned self] deviceId, _, appBundleId -> Result<String, Swift.Error> in
            let cmd: ShellOutCommand = .simctlUninstallApp(device: deviceId, appBundleIdentifier: appBundleId)
            return self.runCommand(cmd)
        }

        server.onSetStatusBarOverride { [unowned self] deviceId, _, overrides -> Result<String, Swift.Error> in
            let cmd: ShellOutCommand = .simctlSetStatusBarOverrides(device: deviceId,
                                                                    overrides: overrides)

            return self.runCommand(cmd)
        }

        server.onClearStatusBarOverrides { [unowned self] deviceId, _ -> Result<String, Swift.Error> in
            let cmd: ShellOutCommand = .simctlClearStatusBarOverrides(device: deviceId)

            return self.runCommand(cmd)
        }
    }
}

// MARK: - CLI
extension SimctlCLI {
    public static func main() {
        let args = CommandLine.arguments

        guard args.count > 1 else {
            showHelp()
            return
        }

        switch args[1] {
        case "-h", "--help":
            showHelp()
        case "start-server":

            let port: SimctlShared.Port
            if args.count == 4, args[2] == "--port", let customPort: SimctlShared.Port = Port(args[3]) {
                port = customPort
            } else {
                port = 8080
            }

            instance.server.startServer(on: port)

        case "list-devices":
            let devices = SimctlCLI.instance.listDevices()
            print("\(devices.map { $0.description }.sorted().joined(separator: "\n"))")

        default:
            showHelp()
        }
    }

    static func showHelp() {
        let help = """
        SimctlCLI - Run simulator controls easily and trigger remote push notifications
        from your app.

        USAGE: simctl <subcommand>

        OPTIONS:
        -h, --help              Show help information.

        SUBCOMMANDS:
        start-server [--port <port>]
        list-devices
        """
        print(help)
    }
}
