//
//  API.swift
//  libapi
//
//  Created by Mason Phillips on 8/9/22.
//

import Foundation

open class API {
    public let baseURL: URL
    public let decoder: JSONDecoder
    public let session: URLSession
    
    public var debugLevel: DebugLevel = .ERROR
    open var apiUrlKey: String = "api_key"
    
    let apiKey: String?
    
    public enum DebugLevel {
        case VERBOSE, ERROR, SILENT
    }
    
    init(baseURL: URL, apiKey: String? = nil) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        
        decoder = JSONDecoder()
        session = URLSession.shared
    }
    
    open func fetch<T: APIRequest>(_ request: T, completion: @escaping (_ data: T.Response?, _ error: Error?) -> Void) {
        let built = self.build(request)
        
        let task = self.session.dataTask(with: built) { data, response, error in
            if let data = data {
                do {
                    let json = try self.decoder.decode(T.Response.self, from: data)
                    completion(json, nil)
                } catch {
                    if self.debugLevel != .SILENT {
                        let decoded = try? self.decoder.decode(String.self, from: data)
                        print(decoded ?? "COULD NOT DECODE STRING")
                    }
                    
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    open func build<T: APIRequest>(_ request: T) -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(request.endpoint), resolvingAgainstBaseURL: false)!
        
        var params = request.params.map { URLQueryItem(name: $0.key, value: $0.value) }
        if request.auth == .apiKey {
            params.append(URLQueryItem(name: self.apiUrlKey, value: apiKey))
        }
        
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = request.method.rawValue
        
        var headers = urlRequest.allHTTPHeaderFields ?? Dictionary<String, String>()
        // if there are duplicate keys, always prefer newer
        headers.merge(request.headers) { _, overriding in overriding }
        if let .bearer(token) = request.auth {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return URLRequest(url: baseURL)
    }
}