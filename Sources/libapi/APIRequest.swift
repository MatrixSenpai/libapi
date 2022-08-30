//
//  APIRequest.swift
//  libapi
//
//  Created by Mason Phillips on 8/9/22.
//

import Foundation

public protocol APIRequest {
    associatedtype Response: Decodable
    
    var endpoint: String { get }
    var method  : HTTPMethod { get }
    var auth    : AuthMethod { get }
    var headers : Dictionary<String, String> { get }
    var params  : Dictionary<String, String> { get }
}

public enum AuthMethod: Equatable {
    case noAuth
    case apiKey
    case bearer(_ token: String)
    
    public static func ==(l: Self, r: Self) -> Bool {
        switch (l, r) {
        case (.noAuth, .noAuth): return true
        case (.apiKey, .apiKey): return true
        case (.bearer(let lk), .bearer(let rk)): return lk == rk
        default:
            return false
        }
    }
}

public enum HTTPMethod {
    case GET, POST, PUT, DELETE, PATCH
    case custom(_ value: String)
    
    public var rawValue: String {
        switch self {
        case .GET   : return "GET"
        case .POST  : return "POST"
        case .PUT   : return "PUT"
        case .DELETE: return "DELETE"
        case .PATCH : return "PATCH"
        case .custom(let v): return v
        }
    }
}
