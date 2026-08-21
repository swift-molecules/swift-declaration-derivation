import Declaration_Derivation_Diagnostics
public import Declaration_Derivation_Model
public import SwiftSyntax
public import SwiftSyntaxMacros

public struct DeclarationDerivationMacro: MemberMacro {
}

extension DeclarationDerivationMacro {

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
