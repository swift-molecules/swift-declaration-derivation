// Declaration.Derivation.Diagnostic.Code.swift

public import DeclarationDerivationModel

extension Declaration.Derivation.Diagnostic {
    /// The closed set of stable diagnostic codes.
    ///
    /// Raw values are the durable identifiers: they appear in rendered
    /// diagnostics, receipts and fixtures, and never change meaning within
    /// a contract revision.
    public enum Code: String, Hashable, Sendable, CaseIterable {
        /// The source declaration is malformed for derivation — for example
        /// a stored property without an explicit type annotation.
        case malformedDeclaration = "declaration.derivation.malformed-declaration"

        /// The declaration kind is outside IR schema v1.
        case unsupportedDeclarationKind = "declaration.derivation.unsupported-declaration-kind"

        /// The declaration or one of its members has an empty name.
        case emptyDeclarationName = "declaration.derivation.empty-declaration-name"

        /// Two members would own the same generated output, so ownership of
        /// the derived interface is ambiguous.
        case ambiguousOwnership = "declaration.derivation.ambiguous-ownership"
    }
}

extension Declaration.Derivation.Diagnostic.Code {

        /// The stable textual identifier of the code.
        public var identifier: String {
            rawValue
        }}
