// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "libapi",
    products: [
        .library(name: "libapi", targets: ["libapi"]),
        .library(name: "libapi+rxswift", targets: ["libapi+rxswift"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
    ],
    targets: [
        .target(name: "libapi", dependencies: []),
        .target(name: "libapi+rxswift", dependencies: ["RxSwift", "libapi"]),
        .testTarget(name: "libapiTests", dependencies: ["libapi"]),
    ]
)
