import Declaration_Derivation_Model
import SwiftParser
import SwiftSyntax

enum FixtureCorpus {
}

extension FixtureCorpus {

    static let zeroMemberStructure = "struct Empty {}"

    static let singleMemberStructure = """
        struct Single {
            let value: Int
        }
        """

    static let defaultPreservingStructure = """
        struct Point {
            let x: Int
            let y: Int = 0
            var label: String = "origin"
        }
        """

    static let enumeration = """
        enum Direction {
            case north
            case south
            case vector(Int, Int)
        }
        """

    static let zeroCaseEnumeration = "enum Never2 {}"

    static let actor = """
        actor Counter {
            var count: Int = 0
        }
        """

    static let malformedStructure = """
        struct Bad {
            let x = 1
        }
        """

    static let unsupportedClass = "class Reference {}"

    static let contract = Declaration.GenerationContract(
        revision: Declaration.GenerationContract.Revision("1"),
        schemaVersion: .version1,
        packageVersionPin: Declaration.GenerationContract.PackageVersionPin(
            "swift-primitives/swift-declaration-derivation@main"
        )
    )

    static func declaration(_ source: String) -> DeclSyntax {
        let file = Parser.parse(source: source)
        guard let declaration = file.statements.first?.item.as(DeclSyntax.self) else {
            fatalError("fixture does not parse to a declaration")
        }
        return declaration
    }
}
