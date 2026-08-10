// Expansion Tests.swift

import Declaration_Derivation_Diagnostics
import Declaration_Derivation_Model
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

@testable import DeclarationDerivationMacros

// MARK: - Macro registry

private let expansionHostMacros: [String: MacroSpec] = [
    "DeclarationDerivation": MacroSpec(type: Declaration.Derivation.ExpansionHost.self)
]

// MARK: - Swift Testing adapter

/// Bridges the generic macro-test support's framework-agnostic failure
/// handler to Swift Testing issue recording.
private func expectMacroExpansion(
    _ originalSource: String,
    expandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    fileID: StaticString = #fileID,
    filePath: StaticString = #filePath,
    line: UInt = #line,
    column: UInt = #column
) {
    assertMacroExpansion(
        originalSource,
        expandedSource: expandedSource,
        diagnostics: diagnostics,
        macroSpecs: expansionHostMacros,
        failureHandler: { failure in
            Issue.record(
                Comment(rawValue: failure.message),
                sourceLocation: SourceLocation(
                    fileID: failure.location.fileID.description,
                    filePath: failure.location.filePath.description,
                    line: Int(failure.location.line),
                    column: Int(failure.location.column)
                )
            )
        },
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
    )
}

// MARK: - Expansion fixtures (the expected sources are the API snapshot of the expanded interface)

private let structureFixture = """
    @DeclarationDerivation
    struct Point {
        let x: Int
        let y: Int = 0
    }
    """

private let structureFixtureExpansion = """
    struct Point {
        let x: Int
        let y: Int = 0

        public init(
            x: Int
        ) {
            self.x = x
        }

        public static var declarationDerivationProvenance: String {
            "contract-revision=1;ir-schema=v1;package-version-pin=swift-primitives/swift-declaration-derivation@main"
        }
    }
    """

private let zeroMemberFixture = """
    @DeclarationDerivation
    struct Empty {
    }
    """

private let zeroMemberFixtureExpansion = """
    struct Empty {

        public init() {
        }

        public static var declarationDerivationProvenance: String {
            "contract-revision=1;ir-schema=v1;package-version-pin=swift-primitives/swift-declaration-derivation@main"
        }
    }
    """

private let enumerationFixture = """
    @DeclarationDerivation
    enum Direction {
        case north
        case south
    }
    """

private let enumerationFixtureExpansion = """
    enum Direction {
        case north
        case south

        public var derivedCaseName: String {
            switch self {
            case .north:
                "north"
            case .south:
                "south"
            }
        }

        public static var declarationDerivationProvenance: String {
            "contract-revision=1;ir-schema=v1;package-version-pin=swift-primitives/swift-declaration-derivation@main"
        }
    }
    """

private let malformedFixture = """
    @DeclarationDerivation
    struct Bad {
        let x = 1
    }
    """

extension Declaration.Derivation.ExpansionHost {
    @Suite struct Test {
        /// Self-firing control: the fixture corpus expands twice with identical
        /// expansions; the expected sources are the API snapshot.
        @Test func `fixture corpus expands identically twice`() {
            for _ in 1...2 {
                expectMacroExpansion(structureFixture, expandedSource: structureFixtureExpansion)
                expectMacroExpansion(zeroMemberFixture, expandedSource: zeroMemberFixtureExpansion)
                expectMacroExpansion(enumerationFixture, expandedSource: enumerationFixtureExpansion)
            }
        }

        /// Negative control: the malformed fixture expands to nothing and emits
        /// the stable diagnostic.
        @Test func `malformed fixture yields the stable diagnostic`() {
            expectMacroExpansion(
                malformedFixture,
                expandedSource: """
                    struct Bad {
                        let x = 1
                    }
                    """,
                diagnostics: [
                    DiagnosticSpec(
                        message: "declaration.derivation.malformed-declaration [Bad]: stored property 'x' requires an explicit type annotation",
                        line: 1,
                        column: 1
                    )
                ]
            )
        }
    }
}
