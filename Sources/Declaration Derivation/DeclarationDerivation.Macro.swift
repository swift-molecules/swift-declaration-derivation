// DeclarationDerivation.Macro.swift

/// The core attached macro of declaration derivation.
///
/// `@DeclarationDerivation` derives, as members of the attached
/// declaration, the IR schema v1 interface the generation contract owns — a
/// label- and default-preserving memberwise initializer for structures and
/// actors, a stable case-name accessor for enumerations — plus the
/// provenance member the contract mandates. Expansion occurs at build time
/// in the consumer through the `DeclarationDerivationMacros` compiler
/// plugin; no generated source is placed under version control.
@attached(
    member,
    names: named(init), named(derivedCaseName), named(declarationDerivationProvenance)
)
public macro DeclarationDerivation() =
    #externalMacro(module: "DeclarationDerivationMacros", type: "DeclarationDerivationMacro")
