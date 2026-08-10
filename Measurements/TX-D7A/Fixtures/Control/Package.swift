// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "tx-d7a-control-consumer",
    targets: [
        .executableTarget(name: "Consumer")
    ],
    swiftLanguageModes: [.v6]
)
