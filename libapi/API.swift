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
                        print(decoded ?? "COULE NOT DECODE STRING")
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
        
        
        return URLRequest(url: baseURL)
    }
}
