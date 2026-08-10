// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "tx-d7a-measurement",
    products: [
        .executable(
            name: "TX D7A Measurement",
            targets: ["TX D7A Measurement"]
        )
    ],
    targets: [
        .executableTarget(
            name: "TX D7A Measurement",
            path: "Sources"
        ),
        .testTarget(
            name: "TX D7A Measurement Tests",
            dependencies: ["TX D7A Measurement"],
            path: "Tests"
        )
    ],
    swiftLanguageModes: [.v6]
)
