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

public enum AuthMethod {
    case noAuth
    case apiKey
    case basicHTTPAuth(_ token: String)
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
