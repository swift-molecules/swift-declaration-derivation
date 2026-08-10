// Declaration.Derivation.MacroPlugin.swift

import Declaration_Derivation_Diagnostics
import Declaration_Derivation_Model
import SwiftCompilerPlugin
import SwiftSyntaxMacros

/// The compiler-plugin entry point of the derivation family.
///
/// `@main` must attach to a top-level type, so the plugin is the one
/// top-level name of the macros target; the expansion host it provides is
/// `Declaration.Derivation.ExpansionHost`.
@main
struct DeclarationDerivationMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DeclarationDerivationMacro.self
    ]
}
