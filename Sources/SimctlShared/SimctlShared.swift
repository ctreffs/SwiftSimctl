//
//  SimctlShared.swift
//
//
//  Created by Christian Treffs on 18.03.20.
//

import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.UUID
import struct Foundation.Date
import class Foundation.ISO8601DateFormatter

public typealias Port = UInt16

public enum PushNotificationContent {
    /// Path to a push payload .json/.apns file.
    ///
    /// The file must reside on the host machine!
    /// The file must be a JSON file with a valid Apple Push Notification Service payload, including the “aps” key.
    /// It must also contain a top-level “Simulator Target Bundle” with a string value
    /// that matches the target application‘s bundle identifier.
    case file(URL)

    /// Arbitrary json encoded push notification payload.
    ///
    /// The payload must be JSON with a valid Apple Push Notification Service payload, including the “aps” key.
    /// It must also contain a top-level “Simulator Target Bundle” with a string value
    /// that matches the target application‘s bundle identifier.
    case jsonPayload(Data)
}

extension PushNotificationContent {
    enum Keys: String, CodingKey {
        case file
        case jsonPayload
    }
}
extension PushNotificationContent: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        switch self {
        case let .file(url):
            try container.encode(url, forKey: .file)

        case let .jsonPayload(data):
            try container.encode(data, forKey: .jsonPayload)
        }
    }
}

extension PushNotificationContent: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)

        if let url = try container.decodeIfPresent(URL.self, forKey: .file) {
            self = .file(url)
        } else if let data = try container.decodeIfPresent(Data.self, forKey: .jsonPayload) {
            self = .jsonPayload(data)
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "unknown case"))
        }
    }
}

/// Swifter makes all header field keys lowercase so we define them lowercase from the start.
public enum HeaderFieldKey: String {
    case bundleIdentifier = "bundle_identifier"
    case deviceUdid = "device_udid"
    case privacyAction = "privacy_action"
    case privacyService = "privacy_service"
    case deviceName = "device_name"
    case targetBundleIdentifier = "target_bundle_identifier"
    case deviceAppearance = "device_appearance"
}

public enum ServerPath: String {
    case pushNotification = "/simctl/pushNotification"
    case privacy = "/simctl/setPrivacy"
    case renameDevice = "/simctl/renameDevice"
    case terminateApp = "/simctl/terminateApp"
    case deviceAppearance = "/simctl/setDeviceAppearance"
    case iCloudSync = "/simctl/iCloudSync"
    case uninstallApp = "/simctl/uninstallApp"
    case statusBarOverrides = "/simctl/statusBarOverrides"
    case openURL = "/simctl/openUrl"
}

/// Some permission changes will terminate the application if running.
public enum PrivacyAction: String {
    /// Grant access without prompting. Requires bundle identifier.
    case grant
    ///  Revoke access, denying all use of the service. Requires bundle identifier.
    case revoke
    ///  Reset access, prompting on next use. Bundle identifier optional.
    case reset
}

public enum PrivacyService: String {
    /// Apply the action to all services.
    case all
    /// Allow access to calendar.
    case calendar
    /// Allow access to basic contact info.
    case contactsLimited = "contacts-limited"
    /// Allow access to full contact details.
    case contacts
    /// Allow access to location services when app is in use.
    case location
    /// Allow access to location services at all times.
    case locationAlways = "location-always"
    /// Allow adding photos to the photo library.
    case photosAdd = " photos-add"
    /// Allow full access to the photo library.
    case photos
    ///ibrary - Allow access to the media library.
    case media
    /// Allow access to audio input.
    case microphone
    /// Allow access to motion and fitness data.
    case motion
    /// Allow access to reminders.
    case reminders
    /// Allow use of the app with Siri.
    case siri
}

public enum DeviceAppearance: String {
    /// The Light appearance style.
    case light
    /// The Dark appearance style.
    case dark
}

internal protocol StatusBarOverrideArgument {
    var toArgument: String { get }
}

public struct StatusBarOverride {
    public let command: String

    private init(_ argument: StatusBarOverrideArgument) {
        self.command = argument.toArgument
    }

    public static func dataNetwork(_ dataNetworkType: DataNetworkType) -> StatusBarOverride {
        .init(dataNetworkType)
    }

    public static func wifiMode(_ mode: WifiMode) -> StatusBarOverride {
        .init(mode)
    }

    public static func wifiBars(_ bars: WifiBars) -> StatusBarOverride {
        .init(bars)
    }

    public static func cellularMode(_ mode: CellularMode) -> StatusBarOverride {
        .init(mode)
    }

    public static func cellularBars(_ bars: CellularBars) -> StatusBarOverride {
        .init(bars)
    }

    public static func batteryState(_ state: BatteryState) -> StatusBarOverride {
        .init(state)
    }

    public static func operatorName(_ name: OperatorName) -> StatusBarOverride {
        .init(name)
    }

    /// Specify the battery level
    /// - Parameter level: If specified must be 0-100.
    public static func batteryLevel(_ level: BatteryLevel) -> StatusBarOverride {
        .init(level)
    }

    ///  Set the date or time to a fixed value.
    ///  If the string is a valid ISO date string it will also set the date on relevant devices.
    /// - Parameter dateAndTime: Either a plain String or a Date().
    public static func time(_ dateAndTime: Time) -> StatusBarOverride {
        .init(dateAndTime)
    }

    public enum DataNetworkType: String, StatusBarOverrideArgument {
        case wifi
        case thirdGen = "3g"
        case fourthGen = "4g"
        case lte
        case lteA = "lte-a"
        case ltePlus = "lte+"

        var toArgument: String {
            "--dataNetwork \(self.rawValue)"
        }
    }

    public enum WifiMode: String, StatusBarOverrideArgument {
        case searching
        case failed
        case active

        var toArgument: String {
            "--wifiMode \(self.rawValue)"
        }
    }

    public enum WifiBars: Int, StatusBarOverrideArgument {
        case zero = 0
        case one = 1
        case two = 2
        case three = 3

        var toArgument: String {
            "--wifiBars \(self.rawValue)"
        }
    }

    public enum CellularMode: String, StatusBarOverrideArgument {
        case notSupported
        case searching
        case failed
        case active

        var toArgument: String {
            "--cellularMode \(self.rawValue)"
        }
    }

    public enum CellularBars: Int, StatusBarOverrideArgument {
        case zero = 0
        case one = 1
        case two = 2
        case three = 3
        case four = 4

        var toArgument: String {
            "--cellularBars \(self.rawValue)"
        }
    }

    public enum BatteryState: String, StatusBarOverrideArgument {
        case charging
        case charged
        case discharging

        var toArgument: String {
            "--batteryState \(self.rawValue)"
        }
    }

    public struct OperatorName: ExpressibleByStringLiteral, StatusBarOverrideArgument {
        let name: String

        public init(stringLiteral value: String) {
            self.name = value
        }

        var toArgument: String {
            "--operatorName \(name)"
        }
    }

    public struct BatteryLevel: ExpressibleByIntegerLiteral, StatusBarOverrideArgument {
        let level: UInt8

        public init(integerLiteral value: UInt8) {
            self.level = value
        }

        var toArgument: String {
            "--batteryLevel \(level)"
        }
    }

    public struct Time: ExpressibleByStringLiteral, StatusBarOverrideArgument {
        let timeString: String

        /// Set the date or time to a fixed value.
        /// If the string is a valid ISO date string it will also set the date on relevant devices.
        public init(_ date: Date) {
            let iso = ISO8601DateFormatter()
            self.init(stringLiteral: iso.string(from: date))
        }

        public init(stringLiteral value: String) {
            self.timeString = value
        }

        var toArgument: String {
            "--time \(timeString)"
        }
    }
}

extension StatusBarOverride: Hashable { }
extension StatusBarOverride: Equatable { }
extension StatusBarOverride: Codable { }

public struct SimulatorDeviceListing {
    public enum Keys: String, CodingKey {
        case devices
    }

    public let devices: [SimulatorDevice]
}

extension SimulatorDeviceListing: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        let dict = try container.decode([String: [SimulatorDevice]].self, forKey: .devices)
        self.devices = dict.values.flatMap { $0 }
    }
}

public struct SimulatorDevice {
    public let udid: UUID
    public let name: String
    public let isAvailable: Bool
    public let deviceTypeIdentifier: String
    public let state: State
    public let logPath: URL
    public let dataPath: URL
}
extension SimulatorDevice {
    public var deviceId: String {
        udid.uuidString
    }
}

extension SimulatorDevice: CustomStringConvertible {
    public var description: String {
        "<SimulatorDevice[\(deviceId)]: \(name) (\(state))>"
    }
}

extension SimulatorDevice {
    public enum State: String {
        case shutdown = "Shutdown"
        case booted = "Booted"
    }
}

extension SimulatorDevice: Decodable { }
extension SimulatorDevice.State: Decodable { }

public struct URLContainer: Codable {
    public let url: URL
    
    public init(url: URL) {
        self.url = url
    }
}
