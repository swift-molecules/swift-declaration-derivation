// swift-tools-version: 6.3.3

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-declaration-derivation",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        // MARK: - Namespace (per [MOD-017])
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
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "602.0.0"..<"603.0.0"),
    ],
    targets: [
        // MARK: - Namespace (per [MOD-017])
        // TX-D0 bootstrap scaffold; the D1 transaction owns the semantic
        // content (the shared declaration IR, analysis and deterministic emission core).
        .target(
            name: "Declaration Derivation",
            dependencies: ["DeclarationDerivationMacros"]
        ),
        // MARK: - Normalized declaration model (Declaration.Node, Declaration.IR, Declaration.GenerationContract)
        .target(
            name: "Declaration Derivation Model",
            dependencies: []
        ),
        // MARK: - Stable diagnostics (Declaration.Derivation.Diagnostic)
        .target(
            name: "Declaration Derivation Diagnostics",
            dependencies: [
                "Declaration Derivation Model",
            ]
        ),
        // MARK: - Analysis rules over the normalized IR
        .target(
            name: "Declaration Derivation Analysis",
            dependencies: [
                "Declaration Derivation Model",
                "Declaration Derivation Diagnostics",
            ]
        ),
        // MARK: - Deterministic emission
        .target(
            name: "Declaration Derivation Emission",
            dependencies: [
                "Declaration Derivation Model",
                "Declaration Derivation Diagnostics",
            ]
        ),
        // MARK: - SwiftSyntax boundary (SwiftSyntax stays here and in the compiler plugin only)
        .target(
            name: "Declaration SwiftSyntax Adapter",
            dependencies: [
                "Declaration Derivation Model",
                "Declaration Derivation Diagnostics",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ]
        ),
        // MARK: - Attached-macro expansion host (thin adapter over the core; build-time only, excluded from Embedded)
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
