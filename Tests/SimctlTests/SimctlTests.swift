//
//  SimctlLibTests.swift
//
//
//  Created by Christian Treffs on 18.03.20.
//

import Simctl
import XCTest

/*
 Camera:       com.apple.camera
 AppStore:     com.apple.AppStore
 Contacts:     com.apple.MobileAddressBook
 Mail:         com.apple.mobilemail
 GameCenter:   com.apple.gamecenter
 MobileSafari: com.apple.mobilesafari
 Preferences:  com.apple.Preferences
 iPod:         com.apple.mobileipod
 Photos:       com.apple.mobileslideshow
 Calendar:     com.apple.mobilecal
 Clock:        com.apple.mobiletimer

 */

let payload: String = """
{
"Simulator Target Bundle": "<#YOUR_BUNDLE_ID#>",
"aps": {
"alert": {
"body": "A very good body...",
"badge": 1,
"title": "My special title!"
}
}
}
"""

class SimctlLibTests: XCTestCase {
    lazy var simctl = SimctlClient(SimulatorEnvironment(bundleIdentifier: "<#YOUR_BUNDLE_ID#>",
                                                        host: .localhost(port: 8080))!)

    func testRequestPushNotification() {
        let exp = expectation(description: "\(#function)")

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
