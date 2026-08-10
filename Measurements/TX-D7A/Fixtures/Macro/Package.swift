// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "tx-d7a-macro-consumer",
    dependencies: [
        .package(path: "../../../..")
    ],
    targets: [
        .executableTarget(
            name: "Consumer",
            dependencies: [
                .product(
                    name: "Declaration Derivation",
                    package: "swift-declaration-derivation"
                )
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
