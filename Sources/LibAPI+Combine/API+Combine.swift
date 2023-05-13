//
//  API+Combine.swift
//  
//
//  Created by Mason Phillips on 5/11/23.
//

import Foundation
import LibAPI
import Combine

public extension API {
    func request<T: APIRequest>(_ request: T) -> AnyPublisher<T.Response, Error> {
        let urlRequest = self.build(request)
        let hashValue = request.hashValue
        guard self.checkOrHold(hashValue) else {
            return Fail(error: APIError.duplicateRequest).eraseToAnyPublisher()
        }
        return self.urlSession.dataTaskPublisher(for: urlRequest)
            .tryMap { [weak self] element -> Data in
                guard
                    let response = element.response as? HTTPURLResponse,
                    200...300 ~= response.statusCode
                else { throw APIError.unknownURLResponse(element.response) }

                self?.currentRequests.remove(hashValue)

                return element.data
            }
            .decode(type: T.Response.self, decoder: self.decoder)
            .eraseToAnyPublisher()
    }
}
