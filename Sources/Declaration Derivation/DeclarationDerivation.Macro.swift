@attached(
    member,
    names: named(init),
    named(derivedCaseName),
    named(declarationDerivationProvenance)
)
public macro DeclarationDerivation() =
    #externalMacro(module: "DeclarationDerivationMacros", type: "DeclarationDerivationMacro")
