//
//  HTTPMethod.swift
//  
//
//  Created by Mason Phillips on 5/9/23.
//

import Foundation

/// Definition of different possible request methods
public enum HTTPMethod: String, CaseIterable, Equatable {
    /// HTTP Get Request
    case `get` = "GET"
    /// HTTP Head Request
    case head = "HEAD"
    /// HTTP Post Request
    case post = "POST"
    /// HTTP Put Request
    case put = "PUT"
    /// HTTP Delete Request
    case delete = "DELETE"
    /// HTTP Connect Request
    case connect = "CONNECT"
    /// HTTP Options Request
    case options = "OPTIONS"
    /// HTTP Trace Request
    case trace = "TRACE"
    /// HTTP Patch Request
    case patch = "PATCH"
}
