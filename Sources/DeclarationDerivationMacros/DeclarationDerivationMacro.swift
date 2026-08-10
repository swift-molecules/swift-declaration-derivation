// DeclarationDerivationMacro.swift

import Declaration_Derivation_Diagnostics
public import Declaration_Derivation_Model
public import SwiftSyntax
public import SwiftSyntaxMacros

/// The resolvable implementation coordinate of the `@DeclarationDerivation`
/// attached macro.
///
/// The compiler plugin resolves a macro implementation by exact
/// `module.type` reflection name, and a type nested in a namespace declared
/// by another module reflects under *that* module. So
/// `Declaration.Derivation.ExpansionHost` — which is nested in
/// `Declaration`, a type of `Declaration_Derivation_Model` — cannot satisfy a
/// `DeclarationDerivationMacros.…` coordinate however it is spelled. This
/// top-level type is that coordinate; it carries no behaviour of its own and
/// forwards every expansion to the shared host.
public struct DeclarationDerivationMacro: MemberMacro {
}

extension DeclarationDerivationMacro {
    /// Forwards the member expansion to the shared expansion host.
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws(Declaration.Derivation.Diagnostic) -> [DeclSyntax] {
        try Declaration.Derivation.ExpansionHost.expansion(
            of: node,
            providingMembersOf: declaration,
            conformingTo: protocols,
            in: context
        )
    }
}
