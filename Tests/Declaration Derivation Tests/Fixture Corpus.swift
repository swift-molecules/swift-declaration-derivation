// Fixture Corpus.swift

import Declaration_Derivation_Model
import SwiftParser
import SwiftSyntax

/// The TX-D1 fixture corpus: the declaration forms IR schema v1 must cover,
/// plus the malformed and unsupported negatives.
enum FixtureCorpus {
}

extension FixtureCorpus {
    /// Zero-member structure.
    static let zeroMemberStructure = "struct Empty {}"

    /// Single-member structure.
    static let singleMemberStructure = """
        struct Single {
            let value: Int
        }
        """

    /// Default-preserving structure with several members.
    static let defaultPreservingStructure = """
        struct Point {
            let x: Int
            let y: Int = 0
            var label: String = "origin"
        }
        """

    /// Enumeration with cases, including a payload case.
    static let enumeration = """
        enum Direction {
            case north
            case south
            case vector(Int, Int)
        }
        """

    /// Zero-case enumeration.
    static let zeroCaseEnumeration = "enum Never2 {}"

    /// Actor with stored state.
    static let actor = """
        actor Counter {
            var count: Int = 0
        }
        """

    /// Malformed: stored property without an explicit type annotation.
    static let malformedStructure = """
        struct Bad {
            let x = 1
        }
        """

    /// Unsupported declaration kind under IR schema v1.
    static let unsupportedClass = "class Reference {}"

    /// The contract every model-level test emits under.
    static let contract = Declaration.GenerationContract(
        revision: Declaration.GenerationContract.Revision("1"),
        schemaVersion: .version1,
        packageVersionPin: Declaration.GenerationContract.PackageVersionPin(
            "swift-primitives/swift-declaration-derivation@main"
        )
    )

    /// The first declaration parsed from a fixture source.
    static func declaration(_ source: String) -> DeclSyntax {
        let file = Parser.parse(source: source)
        guard let declaration = file.statements.first?.item.as(DeclSyntax.self) else {
            fatalError("fixture does not parse to a declaration")
        }
        return declaration
    }
}
