// swift-tools-version: 6.4

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-declaration-derivation",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(
            name: "Declaration Derivation",
            targets: ["Declaration Derivation"]
        ),
        .library(
            name: "Declaration Derivation Model",
            targets: ["Declaration Derivation Model"]
        ),
        .library(
            name: "Declaration SwiftSyntax Adapter",
            targets: ["Declaration SwiftSyntax Adapter"]
        ),
        .library(
            name: "Declaration Derivation Analysis",
            targets: ["Declaration Derivation Analysis"]
        ),
        .library(
            name: "Declaration Derivation Emission",
            targets: ["Declaration Derivation Emission"]
        ),
        .library(
            name: "Declaration Derivation Diagnostics",
            targets: ["Declaration Derivation Diagnostics"]
        ),
        .library(
            name: "Declaration Derivation Macros",
            targets: ["DeclarationDerivationMacros"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "602.0.0"..<"603.0.0")
    ],
    targets: [

        .target(
            name: "Declaration Derivation",
            dependencies: ["DeclarationDerivationMacros"]
        ),

        .target(
            name: "Declaration Derivation Model",
            dependencies: []
        ),

        .target(
            name: "Declaration Derivation Diagnostics",
            dependencies: [
                "Declaration Derivation Model"
            ]
        ),

        .target(
            name: "Declaration Derivation Analysis",
            dependencies: [
                "Declaration Derivation Model",
                "Declaration Derivation Diagnostics",
            ]
        ),

        .target(
            name: "Declaration Derivation Emission",
            dependencies: [
                "Declaration Derivation Model",
                "Declaration Derivation Diagnostics",
            ]
        ),

        .target(
            name: "Declaration SwiftSyntax Adapter",
            dependencies: [
                "Declaration Derivation Model",
                "Declaration Derivation Diagnostics",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ]
        ),

        .macro(
            name: "DeclarationDerivationMacros",
            dependencies: [
                "Declaration Derivation Model",
                "Declaration Derivation Diagnostics",
                "Declaration Derivation Analysis",
                "Declaration Derivation Emission",
                "Declaration SwiftSyntax Adapter",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "Declaration Derivation Consumer Tests",
            dependencies: ["Declaration Derivation"]
        ),
        .testTarget(
            name: "Declaration Derivation Tests",
            dependencies: [
                "Declaration Derivation Model",
                "Declaration Derivation Diagnostics",
                "Declaration Derivation Analysis",
                "Declaration Derivation Emission",
                "Declaration SwiftSyntax Adapter",
                .product(name: "SwiftParser", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "Declaration Derivation Macros Tests",
            dependencies: [
                "DeclarationDerivationMacros",
                "Declaration Derivation Model",
                "Declaration Derivation Diagnostics",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
