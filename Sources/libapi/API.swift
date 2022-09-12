//
//  API.swift
//  libapi
//
//  Created by Mason Phillips on 8/9/22.
//

import Foundation

public typealias APIResponse<T: APIRequest> = ((_ data: T.Response?, _ error: Error?) -> Void)

open class API {
    public let baseURL: URL
    public let decoder: JSONDecoder
    public let session: URLSession
    public let logger : APILogger
    
    open var apiUrlKey: String = "api_key"
    
    let apiKey: String?
    
    public enum APIError: Error {
        case emptyResponse(_ status: Int)
        case badResponse(_ status: Int)
    }
    
    public init(baseURL: URL, apiKey: String? = nil, logger: APILogger = DefaultLogger()) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.logger = logger
        
        decoder = JSONDecoder()
        session = URLSession.shared
    }
    
    open func fetch<T: APIRequest>(_ request: T, completion: @escaping APIResponse<T>) {
        let built = self.build(request)

        let task = self.session.dataTask(with: built) { data, response, error in
            self.handleResponse(request, data: data, response: response, error: error, completion: completion)
        }
        
        task.resume()
    }
    
    open func build<T: APIRequest>(_ request: T) -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(request.endpoint), resolvingAgainstBaseURL: false)!
        
        var params = request.params.map { URLQueryItem(name: $0.key, value: $0.value) }
        if request.auth == .apiKey {
            params.append(URLQueryItem(name: self.apiUrlKey, value: apiKey))
        }
        components.queryItems = params
        
        var urlRequest = URLRequest(url: components.url!)
        urlRequest.httpMethod = request.method.rawValue
        
        var headers = urlRequest.allHTTPHeaderFields ?? Dictionary<String, String>()
        // if there are duplicate keys, always prefer newer
        headers.merge(request.headers) { _, overriding in overriding }
        if case let .bearer(token) = request.auth {
            headers["Authorization"] = "Bearer \(token)"
        }

        logger.info("<API> URL Request built: \(components.string ?? "URL FAILED TO BUILD")", file: #file, function: #function, line: #line)
        return urlRequest
    }
    
    open func handleResponse<T: APIRequest>(_ request: T, data: Data?, response: URLResponse?, error: Error?, completion: @escaping APIResponse<T>) -> Void {
        if let data = data {
            do {
                let json = try self.decoder.decode(T.Response.self, from: data)
                logger.info("<API> Response Recieved: \(json)", file: #file, function: #function, line: #line)
                completion(json, nil)
            } catch {
                let decoded = try? self.decoder.decode(String.self, from: data)
                logger.error("<API> Unexpected Response: \(decoded ?? "COULD NOT DECODE RESPONSE AS STRING")", file: #file, function: #function, line: #line)

                completion(nil, error)
            }
            
        } else if let response = response as? HTTPURLResponse {
            logger.warning("<API> HTTP response without body: \(response.statusCode)", file: #file, function: #function, line: #line)
            if 200..<400 ~= response.statusCode {
                completion(nil, APIError.emptyResponse(response.statusCode))
            } else {
                completion(nil, APIError.badResponse(response.statusCode))
            }
        } else {
            completion(nil, error)
        }
    }
}
