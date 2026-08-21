import Declaration_Derivation_Analysis
import Declaration_Derivation_Diagnostics
import Declaration_Derivation_Emission
public import Declaration_Derivation_Model
import Declaration_SwiftSyntax_Adapter
public import SwiftSyntax
public import SwiftSyntaxMacros

extension Declaration.Derivation {

    public struct ExpansionHost: MemberMacro {
    }
}

extension Declaration.Derivation.ExpansionHost {

    public static let contract = Declaration.GenerationContract(
        revision: Declaration.GenerationContract.Revision("1"),
        schemaVersion: .version1,
        packageVersionPin: Declaration.GenerationContract.PackageVersionPin(
            "swift-primitives/swift-declaration-derivation@main"
        )
    )

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws(Declaration.Derivation.Diagnostic) -> [DeclSyntax] {
        let adapter = Declaration.SwiftSyntaxAdapter()
        let intermediateRepresentation = try adapter.intermediateRepresentation(
            from: declaration
        )
        let analyzed = try Declaration.Derivation.Analyzer().analyze(
            intermediateRepresentation
        )
        let emitter = Declaration.Derivation.Emitter(contract: Self.contract)
        return try emitter.memberDeclarations(for: analyzed).map { member in
            DeclSyntax("\(raw: member)")
        }
    }
}
