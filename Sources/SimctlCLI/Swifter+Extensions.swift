//
//  File.swift
//
//
//  Created by Christian Treffs on 18.03.20.
//

import SimctlShared
import Swifter

extension HttpRequest {
    func headerValue(for key: HeaderFieldKey) -> String? {
        self.headers[key.rawValue]
    }

    func headerValue<V>(for key: HeaderFieldKey, _ initWith: (String) -> V?) -> V? {
        guard let string = headerValue(for: key) else {
            return nil
        }

        return initWith(string)
    }

    func headerValue<V>(for key: HeaderFieldKey) -> V? where V: RawRepresentable, V.RawValue == String {
        headerValue(for: key) { V(rawValue: $0) }
    }
}
