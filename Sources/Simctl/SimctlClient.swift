//
//  SimctlClient.swift
//
//
//  Created by Christian Treffs on 18.03.20.
//

import struct Foundation.UUID
import struct Foundation.Data
import class Foundation.URLSession
import SimctlShared
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#else
#error("Unsupported platform!")
#endif

/// SimctlClient provides methods to trigger remote execution of simctl commands from your app on a local machine.
/// This is acchieved by opening a client-server connection and sending requests to the server
/// which in turn trigger execution of local commands on the server machine.
public class SimctlClient {
    /// Address and port to the host machine.
    static var host: Host = .localhost(port: 8080)

    let session: URLSession
    let env: SimctlClientEnvironment

    /// Start client in a simulator environment.
    /// - Parameter simEnv: The simulator environment configuration.
    public convenience init(_ simEnv: SimulatorEnvironment) {
        self.init(environment: simEnv)
    }

    /// Start client in a given environment.
    public init(environment: SimctlClientEnvironment) {
        session = URLSession(configuration: .default)
        Self.host = environment.host
        self.env = environment
    }

    /// Request a push notification to be send to this app.
    /// - Parameters:
    ///   - notification: The notifcation payload to be send.
    ///   - completion: Result callback of the call. Use this to wait for an expectation to fulfull in a test case.
    public func requestPushNotification(_ notification: PushNotificationContent, _ completion: @escaping DataTaskCallback) {
        dataTask(.postPushNotification(env, notification)) { result in
            completion(result)
        }
    }

    /// Request a change in privacy settings for this app.
    /// - Parameters:
    ///   - action: The privacy action to be taken
    ///   - service: The service to be addressed.
    ///   - completion: Result callback of the call. Use this to wait for an expectation to fulfull in a test case.
    public func requestPrivacyChange(action: PrivacyAction, service: PrivacyService, _ completion: @escaping DataTaskCallback) {
        dataTask(.setPrivacy(env, action, service), completion)
    }
}

// MARK: - Enviroment {
public protocol SimctlClientEnvironment {
    var host: SimctlClient.Host { get }
    var bundleIdentifier: String? { get }
    var deviceUdid: UUID { get }
}
public struct SimulatorEnvironment: SimctlClientEnvironment {
    /// The host address and port of SimctlCLI server.
    public let host: SimctlClient.Host

    /// The bundle identifier of the app you want to address.
    public let bundleIdentifier: String?

    /// The Udid of the device or simulator you want to address.
    public let deviceUdid: UUID

    /// Initialize a simulator environment.
    /// - Parameters:
    ///   - host: The host and port of the SimctlCLI server.
    ///   - bundleIdentifier: The bundle identifier of the app you want to interact with.
    ///   - deviceUdid: The Udid of the device you want to interact with.
    public init(host: SimctlClient.Host, bundleIdentifier: String?, deviceUdid: UUID) {
        self.host = host
        self.bundleIdentifier = bundleIdentifier
        self.deviceUdid = deviceUdid
    }

    /// Initialize a simulator environment.
    /// - Parameters:
    ///   - host: The host and port of the SimctlCLI server.
    ///   - bundle: Bundle of the app you want to interact with.
    ///   - processInfo: The process info from where to get the device Udid.
    public init?(host: SimctlClient.Host, bundle: Bundle, processInfo: ProcessInfo) {
        guard let udid = Self.deviceId(processInfo) else {
            return nil
        }

        self.init(host: host,
                  bundleIdentifier: bundle.bundleIdentifier,
                  deviceUdid: udid)
    }

    /// Initialize a simulator environment.
    ///
    /// The device Udid of this device will be extracted from the process environment for you.
    ///
    /// - Parameters:
    ///   - bundleIdentifier: The bundle identifier of the app you want to interact with.
    ///   - host: The host and port of the SimctlCLI server.
    public init?(bundleIdentifier: String, host: SimctlClient.Host) {
        guard let udid = Self.deviceId(ProcessInfo()) else {
            return nil
        }
        self.init(host: host, bundleIdentifier: bundleIdentifier, deviceUdid: udid)
    }

    static func deviceId(_ processInfo: ProcessInfo) -> UUID? {
        guard let udidString = processInfo.environment[ProcessEnvironmentKey.simulatorUdid.rawValue] else {
            return nil
        }

        return UUID(uuidString: udidString)
    }
}

// MARK: - Process Info

enum ProcessEnvironmentKey: String {
    case simulatorAudioDevicesPlistPath = "SIMULATOR_AUDIO_DEVICES_PLIST_PATH"
    case simulatorAudioSettingsPath = "SIMULATOR_AUDIO_SETTINGS_PATH"
    case simulatorBootTime = "SIMULATOR_BOOT_TIME"
    case simulatorCapabilities = "SIMULATOR_CAPABILITIES"
    case simulatorDeviceName = "SIMULATOR_DEVICE_NAME"
    case simulatorExtendedDisplayProperties = "SIMULATOR_EXTENDED_DISPLAY_PROPERTIES"
    case simulatorFramebufferFramework = "SIMULATOR_FRAMEBUFFER_FRAMEWORK"
    case simulatorHIDSystemManager = "SIMULATOR_HID_SYSTEM_MANAGER"
    case simulatorHostHome = "SIMULATOR_HOST_HOME"
    case simulatorLegacyAssetSuffic = "SIMULATOR_LEGACY_ASSET_SUFFIX"
    case simulatorLogRoot = "SIMULATOR_LOG_ROOT"
    case simulatorMainScreenHeight = "SIMULATOR_MAINSCREEN_HEIGHT"
    case simulatorMainScreenPitch = "SIMULATOR_MAINSCREEN_PITCH"
    case simulatorMainScreenScale = "SIMULATOR_MAINSCREEN_SCALE"
    case simulatorMainScreenWidth = "SIMULATOR_MAINSCREEN_WIDTH"
    case simulatorMemoryWarnings = "SIMULATOR_MEMORY_WARNINGS"
    case simulatorModelIdentifier = "SIMULATOR_MODEL_IDENTIFIER"
    case simulatorProductClass = "SIMULATOR_PRODUCT_CLASS"
    case simulatorRoot = "SIMULATOR_ROOT"
    case simulatorRuntimeBuildVersion = "SIMULATOR_RUNTIME_BUILD_VERSION"
    case simulatorRuntimeVersion = "SIMULATOR_RUNTIME_VERSION"
    case simulatorSharedResourcesDirectory = "SIMULATOR_SHARED_RESOURCES_DIRECTORY"
    case simulatorUdid = "SIMULATOR_UDID"
    case simulatorVersionInfo = "SIMULATOR_VERSION_INFO"
}

// MARK: - Host
extension SimctlClient {
    public struct Host {
        let host: String

        public init(_ host: String) {
            self.host = host
        }
    }
}
extension SimctlClient.Host {
    public static func localhost(port: SimctlShared.Port) -> SimctlClient.Host { SimctlClient.Host("http://localhost:\(port)") }
}
extension SimctlClient.Host: Equatable { }

// MARK: - Errors
extension SimctlClient {
    public enum Error: Swift.Error {
        case noHttpResponse(Route)
        case unexpectedHttpStatusCode(Route, HTTPURLResponse)
        case noData(Route, HTTPURLResponse)
        case serviceError(Swift.Error)
    }
}

// MARK: - Routing
extension SimctlClient {
    public enum Route {
        case postPushNotification(SimctlClientEnvironment, PushNotificationContent)
        case setPrivacy(SimctlClientEnvironment, PrivacyAction, PrivacyService)

        @inlinable var httpMethod: HttpMethod {
            switch self {
            case .postPushNotification:
                return .post

            case .setPrivacy:
                return .get
            }
        }

        @inlinable var path: String {
            switch self {
            case .postPushNotification:
                return "/simctl/pushNotification"
            case .setPrivacy:
                return "/simctl/privacy"
            }
        }

        @inlinable var queryItems: [URLQueryItem]? {
            switch self {
            case .postPushNotification,
                 .setPrivacy:
                return nil
            }
        }

        @inlinable var headerFields: [HeaderField] {
            func setEnv(_ env: SimctlClientEnvironment) -> [HeaderField] {
                var fields: [HeaderField] = [
                    .init(.deviceUdid, env.deviceUdid)
                ]
                if let bundleId = env.bundleIdentifier {
                    fields.append(.init(.bundleIdentifier, bundleId))
                }
                return fields
            }

            switch self {
            case let .postPushNotification(env, _):
                return setEnv(env)

            case let .setPrivacy(env, action, service):
                var fields = setEnv(env)

                fields.append(HeaderField(.privacyAction, action.rawValue))
                fields.append(HeaderField(.privacyService, service.rawValue))
                return fields
            }
        }

        @inlinable var httpBody: Data? {
            let encoder = JSONEncoder()
            switch self {
            case let .postPushNotification(_, notification):
                return try? encoder.encode(notification)

            case .setPrivacy:
                return nil
            }
        }

        func asURL() -> URL {
            let urlString: String = SimctlClient.host.host + path
            guard var components = URLComponents(string: urlString) else {
                fatalError("no valid url \(urlString)")
            }

            components.queryItems = self.queryItems

            return components.url!
        }

        func asURLRequest() -> URLRequest {
            var request = URLRequest(url: asURL())

            request.httpMethod = httpMethod.rawValue

            // let defaultHeaderFields: [HeaderField] = [
            //     // 'Authorization: OAuth [your access token]'
            //     .init("Authorization", "OAuth " + developerAccessToken)
            // ]
            //
            // let allHeaderFields: [HeaderField] = headerFields + defaultHeaderFields
            //
            for field in headerFields {
                request.addValue(field.value, forHTTPHeaderField: field.headerField.rawValue)
            }

            request.httpBody = httpBody

            return request
        }
    }
}

// MARK: - Data tasks
extension SimctlClient {
    public typealias DataTaskCallback = (Result<Data, SimctlClient.Error>) -> Void
    public typealias DecodedTaskCallback<Value> = (Result<Value, Swift.Error>) -> Void where Value: Decodable

    func dataTaskDecoded<Value>(_ route: Route, _ completion: @escaping DecodedTaskCallback<Value>) where Value: Decodable {
        dataTask(route) { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
                return

            case let .success(data):
                do {
                    let decoder = JSONDecoder()
                    let value: Value = try decoder.decode(Value.self, from: data)
                    completion(.success(value))
                    return
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    func dataTask(_ route: Route, _ completion: @escaping DataTaskCallback) {
        let task = session.dataTask(with: route.asURLRequest()) { data, urlResponse, error in
            if let error = error {
                completion(.failure(Error.serviceError(error)))
                return
            }

            guard let response = urlResponse as? HTTPURLResponse else {
                completion(.failure(Error.noHttpResponse(route)))
                return
            }

            guard response.statusCode == 200 else {
                completion(.failure(Error.unexpectedHttpStatusCode(route, response)))
                return
            }

            guard let data: Data = data else {
                completion(.failure(Error.noData(route, response)))
                return
            }

            completion(.success(data))
        }
        task.resume()
    }
}

// MARK: - HTTP Methods
@usableFromInline
enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}
extension HttpMethod: Equatable { }

// MARK: - Header field
@usableFromInline
struct HeaderField {
    let headerField: HeaderFieldKey
    let value: String

    public init(_ headerField: HeaderFieldKey, _ string: String) {
        self.headerField = headerField
        self.value = string
    }

    public init(_ headerField: HeaderFieldKey, _ bool: Bool) {
        self.headerField = headerField
        self.value = String(bool)
    }

    public init(_ headerField: HeaderFieldKey, _ int: Int) {
        self.headerField = headerField
        self.value = String(int)
    }

    public init(_ headerField: HeaderFieldKey, _ uuid: UUID) {
        self.headerField = headerField
        self.value = uuid.uuidString
    }
}
extension HeaderField: Equatable { }
