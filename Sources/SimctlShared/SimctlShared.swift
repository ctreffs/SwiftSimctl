//
//  SimctlShared.swift
//
//
//  Created by Christian Treffs on 18.03.20.
//

import struct Foundation.URL
import struct Foundation.Data
import struct Foundation.UUID

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
    case locationAllways = "location-always"
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
