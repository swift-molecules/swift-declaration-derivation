// Declaration.Derivation.Rule.swift

public import DeclarationDerivationDiagnostics
public import DeclarationDerivationModel

extension Declaration.Derivation {
    /// A single analysis rule over the normalized IR.
    ///
    /// Rules are pure and deterministic: the same IR yields the same
    /// verdict — and, on violation, the same diagnostic — on every run.
    public enum Rule: Hashable, Sendable, CaseIterable {
        /// The declaration itself must carry a non-empty name.
        case declarationNameIsNotEmpty

        /// Every member must carry a non-empty name.
        case memberNamesAreNotEmpty

        /// Member names must be unique; duplicates make ownership of the
        /// derived interface ambiguous.
        case memberNamesAreUnique

        /// Structure and actor members must carry a type reference; a
        /// normalized stored property without one is malformed.
        case storedMembersCarryTypeReferences
    }
}

extension Declaration.Derivation.Rule {

        /// The first violation of this rule in the IR, in declaration
        /// order, or `nil` when the rule holds.
        public func violation(
            in intermediateRepresentation: Declaration.IR
        ) -> Declaration.Derivation.Diagnostic? {
            let node = intermediateRepresentation.node
            switch self {
            case .declarationNameIsNotEmpty:
                guard node.name.text.isEmpty else { return nil }
                return Declaration.Derivation.Diagnostic(
                    code: .emptyDeclarationName,
                    subject: nil,
                    detail: "declaration has an empty name"
                )
            case .memberNamesAreNotEmpty:
                guard node.members.contains(where: { $0.name.text.isEmpty }) else {
                    return nil
                }
                return Declaration.Derivation.Diagnostic(
                    code: .emptyDeclarationName,
                    subject: node.name,
                    detail: "a member has an empty name"
                )
            case .memberNamesAreUnique:
                var seen: Set<String> = []
                for member in node.members {
                    if seen.contains(member.name.text) {
                        return Declaration.Derivation.Diagnostic(
                            code: .ambiguousOwnership,
                            subject: node.name,
                            detail: "member '\(member.name.text)' is declared more than once; ownership of the derived interface is ambiguous"
                        )
                    }
                    seen.insert(member.name.text)
                }
                return nil
            case .storedMembersCarryTypeReferences:
                guard node.kind != .enumeration else { return nil }
                for member in node.members where member.typeReference == nil {
                    return Declaration.Derivation.Diagnostic(
                        code: .malformedDeclaration,
                        subject: node.name,
                        detail: "stored member '\(member.name.text)' carries no type reference"
                    )
                }
                return nil
            }
        }}
