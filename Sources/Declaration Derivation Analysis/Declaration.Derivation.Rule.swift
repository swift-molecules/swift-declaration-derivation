public import Declaration_Derivation_Diagnostics
public import Declaration_Derivation_Model

extension Declaration.Derivation {

    public enum Rule: Hashable, Sendable, CaseIterable {

        case declarationNameIsNotEmpty

        case memberNamesAreNotEmpty

        case memberNamesAreUnique

        case storedMembersCarryTypeReferences
    }
}

extension Declaration.Derivation.Rule {

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
                        detail: """
                            member '\(member.name.text)' is declared more than once; \
                            ownership of the derived interface is ambiguous
                            """
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
    }
}
