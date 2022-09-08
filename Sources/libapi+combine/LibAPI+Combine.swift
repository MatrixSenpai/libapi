//
//  File.swift
//  
//
//  Created by Mason Phillips on 9/7/22.
//

import Foundation
import Combine

#if canImport(libapi) && !COCOAPODS
    import libapi
#endif

extension API {
    open func fetch<T: APIRequest>(_ request: T) -> AnyPublisher<T.Response, Error> {
        return Deferred {
            Future { promise in
                let built = self.build(request)

                let task = self.session.dataTask(with: built) { data, response, error in
                    self.handleResponse(request, data: data, response: response, error: error) { data, error in
                        if let data = data {
                            promise(.success(data))
                        } else if let error = error {
                            promise(.failure(error))
                        }
                    }
                }

                task.resume()
            }
        }.eraseToAnyPublisher()
    }
}
