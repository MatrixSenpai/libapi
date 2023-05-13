//
//  API.swift
//  
//
//  Created by Mason Phillips on 4/24/23.
//

import Foundation
import Combine

public enum APIError: Error {
    case decodingError(Error, response: URLResponse?)
    case successfulEmptyResponse(code: Int, response: HTTPURLResponse)
    case failureResponse(code: Int, response: HTTPURLResponse)
    case unknownURLResponse(URLResponse)
    case unknownError(Error)
    case emptyResponseClosure
    case duplicateRequest
}

public protocol API: AnyObject {
    var baseURL        : URL                 { get }
    var encoder        : JSONEncoder         { get }
    var decoder        : JSONDecoder         { get }
    var urlSession     : URLSession          { get }
    var logger         : APILogger?          { get }
    var authentication : AuthenticationInfo? { get set }
    var currentRequests: Set<Int>            { get set }
    var rateLimitHold  : Int                 { get set }
}

public extension API {
    func build<T: APIRequest>(_ request: T) -> URLRequest {
        var url = baseURL.appending(path: request.endpoint)
        url.append(queryItems: request.queryParams())

        if let authentication = authentication, authentication.location == .query {
            url.append(queryItems: [URLQueryItem(name: authentication.key, value: authentication.value)])
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = try? request.httpBody(encoder: encoder)

        request.headers()?.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }

        if let authentication = authentication, authentication.location == .header {
            urlRequest.setValue(authentication.value, forHTTPHeaderField: authentication.key)
        }

        self.logRequest(urlRequest)
        return urlRequest
    }
    func checkOrHold(_ requestValue: Int) -> Bool {
        guard !currentRequests.contains(requestValue) else { return false }
        currentRequests.insert(requestValue)
        return true
    }

    func request<T: APIRequest>(_ request: T, handler: @escaping (Result<T.Response, Error>) -> Void) {
        let urlRequest = self.build(request)
        let hashValue = request.hashValue
        guard self.checkOrHold(hashValue) else { return }
        self.urlSession.dataTask(with: urlRequest) { data, response, error in
            self.logResponse(response)
            if let data = data {
                do {
                    let response = try self.decoder.decode(T.Response.self, from: data)
                    self.currentRequests.remove(hashValue)
                    handler(.success(response))
                } catch {
                    if let string = String(data: data, encoding: .utf8) {
                        self.logger?.error("Failed decoding: \(error)")
                        self.logger?.debug("Stringified response: \(string)")
                    }
                    self.currentRequests.remove(hashValue)
                    handler(.failure(APIError.decodingError(error, response: response)))
                }
            } else if let response = response as? HTTPURLResponse {
                if 200...300 ~= response.statusCode {
                    self.currentRequests.remove(hashValue)
                    handler(.failure(APIError.successfulEmptyResponse(code: response.statusCode, response: response)))
                } else {
                    self.currentRequests.remove(hashValue)
                    handler(.failure(APIError.failureResponse(code: response.statusCode, response: response)))
                }
            } else if let response = response {
                self.currentRequests.remove(hashValue)
                handler(.failure(APIError.unknownURLResponse(response)))
            } else if let error = error {
                self.currentRequests.remove(hashValue)
                handler(.failure(APIError.unknownError(error)))
            } else {
                self.currentRequests.remove(hashValue)
                handler(.failure(APIError.emptyResponseClosure))
            }
        }.resume()
    }

    func request<T: APIRequest>(_ request: T) async throws -> T.Response {
        let urlRequest = self.build(request)
        let hashValue = request.hashValue
        guard self.checkOrHold(hashValue) else { throw APIError.duplicateRequest }
        let (data, response) = try await self.urlSession.data(for: urlRequest)
        if !data.isEmpty {
            self.currentRequests.remove(hashValue)
            return try self.decoder.decode(T.Response.self, from: data)
        } else if let response = response as? HTTPURLResponse {
            if 200...300 ~= response.statusCode {
                self.currentRequests.remove(hashValue)
                throw APIError.successfulEmptyResponse(code: response.statusCode, response: response)
            } else {
                self.currentRequests.remove(hashValue)
                throw APIError.failureResponse(code: response.statusCode, response: response)
            }
        }
        self.currentRequests.remove(hashValue)
        throw APIError.unknownURLResponse(response)
    }

    func logRequest(_ request: URLRequest) {
        guard let logger = logger else { return }
        var str = "HTTP REQUEST FIRED\n"
        str += "REQUEST: \(request.url!.absoluteString) - \(request.httpMethod!)\n"
        let headers = (request.allHTTPHeaderFields?.compactMap { "\($0.key): \($0.value)" })?.joined(separator: ",") ?? "NO HEADERS"
        str += "HEADERS: \(headers)\n"
        let params = request.url!.query()?.description ?? "NO PARAMS"
        str += "QUERY: \(params)"
        logger.debug(str)
    }
    func logResponse(_ response: URLResponse?) {
        guard let response = response as? HTTPURLResponse else { return }
        var str = "HTTP RESPONSE RECEIVED\n"
        str += "RESPONSE: \(response.url!.absoluteString) - \(response.statusCode)\n"
        let headers = (response.allHeaderFields.compactMap { "\($0.key): \($0.value)" }).joined(separator: ",")
        str += "HEADERS: \(headers)\n"
        let params = response.url!.query()?.description ?? "NO PARAMS"
        str += "QUERY: \(params)"
        logger?.debug(str)
    }
}
