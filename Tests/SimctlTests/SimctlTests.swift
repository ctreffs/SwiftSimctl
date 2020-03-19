//
//  SimctlLibTests.swift
//
//
//  Created by Christian Treffs on 18.03.20.
//

import Simctl
import XCTest

class SimctlLibTests: XCTestCase {
    lazy var simctl = SimctlClient(SimulatorEnvironment(bundleIdentifier: "com.mybundle.id",
                                                        host: .localhost(port: 8080))!)
    func testRequestPushNotification() {
        let exp = expectation(description: "\(#function)")

        let payload: String = """
        {
        "Simulator Target Bundle": "com.mybundle.id",
        "aps": {
        "alert": {
        "body": "A very good body...",
        "badge": 1,
        "title": "My special title!"
        }
        }
        }
        """
        let jsonData = payload.data(using: .utf8)!

        simctl.requestPushNotification(.jsonPayload(jsonData)) {
            switch $0 {
            case .success:
                exp.fulfill()

            case let .failure(error):
                XCTFail("\(error)")
            }
        }

        waitForExpectations(timeout: 3.0)
    }

    func testRequestPrivacyChange() {
        let exp = expectation(description: "\(#function)")
        simctl.requestPrivacyChange(action: .grant, service: .contacts) {
            switch $0 {
            case .success:
                exp.fulfill()

            case let .failure(error):
                XCTFail("\(error)")
            }
        }

        waitForExpectations(timeout: 3.0)
    }
}
