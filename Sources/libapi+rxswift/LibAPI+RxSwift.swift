//
//  LibAPI+RxSwift.swift
//  
//  Extends the api to be compatible with RxSwift
//  Created by Mason Phillips on 8/29/22.
//

import Foundation
import RxSwift

#if canImport(libapi) && !COCOAPODS
    import libapi
#endif

extension API {
    open func fetch<T: APIRequest>(_ request: T) -> Single<T.Response> {
        return .create { observer in
            let built = self.build(request)
            
            let task = self.session.dataTask(with: built) { data, response, error in
                self.handleResponse(request, data: data, response: response, error: error) { data, error in
                    if let data = data {
                        observer(.success(data))
                    } else if let error = error {
                        observer(.failure(error))
                    }
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
