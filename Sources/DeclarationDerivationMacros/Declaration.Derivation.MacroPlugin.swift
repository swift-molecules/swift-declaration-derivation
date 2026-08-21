import Declaration_Derivation_Diagnostics
import Declaration_Derivation_Model
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DeclarationDerivationMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DeclarationDerivationMacro.self
    ]
}
