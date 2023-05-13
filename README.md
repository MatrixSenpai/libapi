# LibAPI

A small wrapper around URLSession that allows quick and generic building of api responses and tasks

## How to use

There are two core parts to this wrapper
- The `API` class itself
- The `APIRequest` protocol

#### The `API` class

At its core, the class is very simple. Initialize the class by providing the base URL and a date decoding strategy (either custom or built-in). Then, make a request by building a struct that conforms to the `APIRequest` protocol, passing an instance to `request<T: APIRequest>(_)` and either using the callback or binding it to an RxSwift observable.

However, if you need to add headers, customize params, etc. then override the `build(_ : APIRequest)` method by subclassing the `API` class. If you want headers and params auto-added, call `super.build(request)` inside, or just rewrite the whole thing if you need a custom request method

A simple request works as follows.

```swift
// Assuming we have a struct already that conforms to APIRequest called "CurrentWeatherRequest"

let request = CurrentWeatherRequest(zipcode: "44444")
api.request(request) { response, error in
    // Check for errors and handle the response, which is already deserialized
}
```

#### The `APIRequest` protocol

This is the core structure for making requests and decoding data. 

It contains an associated type that must conform to `Decodable`. This is the type that will be returned by either the completion or the `Single` if you are using RxSwift.

It also contains several properties associated with a request. These must all be set, though some of them (i.e. `method`) can be set to a default value.

In order to use this protocol, create a struct that conforms to this protocol. Any params or headers that must be set can also be created in this struct. A simple example is as follows (using the `CurrentWeatherRequest` example from before)

```swift
struct CurrentWeatherRequest: APIRequest {
    // Assuming we have a struct that conforms to Decodable called "CurrentWeatherResponse"
    // Since we are conforming to Decodable, this could also be wrapped in a Dictionary or Array if necessary
    typealias Response = CurrentWeatherResponse
    
    var endpoint: String { "/current" } // The actual endpoint, without including the base url
    var method  : HTTPMethod { .GET } // The HTTP request type
    var auth    : AuthMethod { .apiKey } // The type of authentication required 
    var headers : Dictionary<String, String> { [:] } // Any headers required (not including the api key)
    var params  : Dictionary<String, String> {
        return [
            "zipcode": String(zipcode),
        ]
    } // Any params required for the request
    
    let zipcode: String
}
```

Generally speaking, it is not advised to expose or use this struct directly. Instead, extend `API` as follows:

```swift
public extension API {
    func getCurrentWeather(_ zip: String, completion: @escaping (Result<T.Response, Error>) -> Void) {
        return self.request(CurrentWeatherRequest(zipcode: zip))
    }
    
    // or with RxSwift
    
    func getCurrentWeather(_ zip: String) -> Single<CurrentWeatherResponse> {
        return self.request(CurrentWeatherRequest(zipcode: zip))
    }
}
```

Then, in your app, simply call `api.getCurrentWeather("44444")` to access it.

## Installation

#### SPM

Include the following line in your dependencies 
```swift
.package(url: "https://github.com/MatrixSenpai/libapi.git", from: "2.0.0")
```

And import it as follows
```swift
.target(name: "MyTarget", dependencies: ["libapi"])
// OR
.target(name: "MyTarget", dependencies: ["libapi", .product(name: "libapi+rxswift", package: "libapi"), "RxSwift"])
// OR
.target(name: "MyTarget", dependencies: ["libapi", .product(name: "libapi+combine", package: "libapi")])
```

#### CocoaPods

Simply include the pod name, as follows
```ruby
# If you DON'T want the extensions
pod 'LibAPI'

# If you want RxSwift
pod 'LibAPI/LibAPI+RxSwift'

# If you want to use Combine instead of RxSwift
pod 'LibAPI/LibAPI+Combine'
```

#### Carthage

Carthage is not, nor will I personally add support in any of my work. Should someone desire to open a PR and include it, do so and I will update the documentation.

## Other Notes

This work is licenced under the GNU GPLv3 license. See the LICENSE.md file for further information.
