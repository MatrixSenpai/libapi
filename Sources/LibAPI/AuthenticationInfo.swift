//
//  AuthenticationInfo.swift
//  
//
//  Created by Mason Phillips on 5/9/23.
//

import Foundation

/// Allows passing in authentication information
public struct AuthenticationInfo {
    let location: Location
    let key: String
    var value: String

    public enum Location {
        case header
        case query
    }

    public init(
        _ location: Location = .query,
        key: String = "api_key",
        value: String
    ) {
        self.location = location
        self.key = key
        self.value = value
    }

    /// Update the key passed in. Typically used with OAuth keys
    public mutating func update(with value: String) {
        self.value = value
    }
}
