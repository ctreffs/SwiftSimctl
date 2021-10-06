//
//  ListDevices.swift
//
//
//  Created by Christian Treffs on 18.03.20.
//

import Foundation
import ShellOut
import SimctlShared
import Swifter
import ArgumentParser

public enum ListDevicesError: Swift.Error {
    case dataConversionFailed
}

struct ListDevices: ParsableCommand {
    
    static var configuration = CommandConfiguration(abstract: "List the simulator devices")


    mutating func run() throws {
        print("\(listDevices().map { $0.description }.sorted().joined(separator: "\n"))")
    }
}

private func listDevices() -> [SimulatorDevice] {
    do {
        let devicesJSONString = try shellOut(to: .simctlList(.devices, true))
        guard let devicesData: Data = devicesJSONString.data(using: .utf8) else {
            throw ListDevicesError.dataConversionFailed
        }
        let decoder = JSONDecoder()
        let listing = try decoder.decode(SimulatorDeviceListing.self, from: devicesData)
        return listing.devices
    } catch {
        return []
    }
}
