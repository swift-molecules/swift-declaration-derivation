// Declaration.Derivation.ExpansionHost.swift

import DeclarationDerivationAnalysis
import DeclarationDerivationDiagnostics
import DeclarationDerivationEmission
public import DeclarationDerivationModel
import DeclarationSwiftSyntaxAdapter
public import SwiftSyntax
public import SwiftSyntaxMacros

extension Declaration.Derivation {
    /// The shared attached-macro expansion host of the derivation family.
    ///
    /// The host is a thin adapter over the core: it normalizes the attached
    /// declaration through `Declaration.SwiftSyntaxAdapter`, validates the
    /// IR through `Declaration.Derivation.Analyzer` and renders members
    /// through `Declaration.Derivation.Emitter`. It receives the attached
    /// declaration only and performs no input or output of any other kind.
    /// Every expansion carries the generation contract's provenance
    /// (contract revision, IR schema version, package version pin) as a
    /// generated member.
    public struct ExpansionHost: MemberMacro {
    }
}

extension Declaration.Derivation.ExpansionHost {
    /// The generation contract this expansion host emits under.
    public static let contract = Declaration.GenerationContract(
        revision: Declaration.GenerationContract.Revision("1"),
        schemaVersion: .version1,
        packageVersionPin: Declaration.GenerationContract.PackageVersionPin(
            "swift-primitives/swift-declaration-derivation@main"
        )
    )

    /// Expands the attached declaration into its derived members.
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
