public import Declaration_Derivation_Model

extension Declaration.Derivation.Diagnostic {

    public enum Code: String, Hashable, Sendable, CaseIterable {

        case malformedDeclaration = "declaration.derivation.malformed-declaration"

        case unsupportedDeclarationKind = "declaration.derivation.unsupported-declaration-kind"

        case emptyDeclarationName = "declaration.derivation.empty-declaration-name"

        case ambiguousOwnership = "declaration.derivation.ambiguous-ownership"
    }
}

extension Declaration.Derivation.Diagnostic.Code {

    public var identifier: String {
        rawValue
    }
}
