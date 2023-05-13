//
//  APIRequest.swift
//  
//
//  Created by Mason Phillips on 4/24/23.
//

import Foundation

/// The structure for a request to a generic API
public protocol APIRequest: Hashable {
    /// The expected response type for this request
    associatedtype Response: Decodable

    var endpoint: String     { get }
    var method  : HTTPMethod { get }

    func headers() -> Dictionary<String, String>?
    func queryParams() -> Array<URLQueryItem>
    func httpBody(encoder: JSONEncoder) throws -> Data?
}

public extension APIRequest {
    var hashValue: Int {
        var hasher = Hasher()
        hasher.combine(endpoint)
        hasher.combine(method.rawValue)

        hasher.combine(
            headers()?.keys.joined(separator: "") ?? ""
        )

        hasher.combine(
            queryParams().map { $0.name }.joined()
        )

        return hasher.finalize()
    }
}
