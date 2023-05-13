//
//  API+RxSwift.swift
//  
//
//  Created by Mason Phillips on 5/11/23.
//

import Foundation
import LibAPI
import RxSwift

public extension API {
    func request<T: APIRequest>(_ request: T) -> Single<T.Response> {
        return Single.create { observer in
            let urlRequest = self.build(request)
            let hashValue = request.hashValue
            guard self.checkOrHold(hashValue) else {
                observer(.failure(APIError.duplicateRequest))
                return Disposables.create()
            }
            let task = self.urlSession.dataTask(with: urlRequest) { data, response, error in
                self.logResponse(response)
                if let data = data {
                    do {
                        let response = try self.decoder.decode(T.Response.self, from: data)
                        self.currentRequests.remove(hashValue)
                        observer(.success(response))
                    } catch {
                        if let string = String(data: data, encoding: .utf8) {
                            self.logger?.error("Failed decoding: \(error)")
                            self.logger?.debug("Stringified response: \(string)")
                        }
                        self.currentRequests.remove(hashValue)
                        observer(.failure(APIError.decodingError(error, response: response)))
                    }
                } else if let response = response as? HTTPURLResponse {
                    if 200...300 ~= response.statusCode {
                        self.currentRequests.remove(hashValue)
                        observer(.failure(APIError.successfulEmptyResponse(code: response.statusCode, response: response)))
                    } else {
                        self.currentRequests.remove(hashValue)
                        observer(.failure(APIError.failureResponse(code: response.statusCode, response: response)))
                    }
                } else if let response = response {
                    self.currentRequests.remove(hashValue)
                    observer(.failure(APIError.unknownURLResponse(response)))
                } else if let error = error {
                    self.currentRequests.remove(hashValue)
                    observer(.failure(APIError.unknownError(error)))
                } else {
                    self.currentRequests.remove(hashValue)
                    observer(.failure(APIError.emptyResponseClosure))
                }
            }
            task.resume()

            return Disposables.create {
                self.currentRequests.remove(hashValue)
                task.cancel()
            }
        }
    }
}
