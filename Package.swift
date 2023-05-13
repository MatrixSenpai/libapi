// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "libapi",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v13)
    ],
    products: [
        .library(name: "LibAPI", targets: ["LibAPI"]),
        .library(name: "LibAPI+Combine", targets: ["LibAPI", "LibAPI+Combine"]),
        .library(name: "LibAPI+RxSwift", targets: ["LibAPI", "LibAPI+RxSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift#installation", from: "6.5.0")
    ],
    targets: [
        .target(name: "LibAPI", dependencies: []),
        .target(name: "LibAPI+Combine", dependencies: ["LibAPI"]),
        .target(name: "LibAPI+RxSwift", dependencies: ["LibAPI", .product(name: "RxSwift", package: "RxSwift#installation")])
    ]
)
