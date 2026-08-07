// Declaration.Derivation.MacroPlugin.swift

import DeclarationDerivationDiagnostics
import DeclarationDerivationModel
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
        Declaration.Derivation.ExpansionHost.self
    ]
}
