// Declaration.SwiftSyntaxAdapter.swift

public import Declaration_Derivation_Diagnostics
public import Declaration_Derivation_Model
public import SwiftSyntax

extension Declaration {
    /// The single SwiftSyntax boundary of the derivation family.
    ///
    /// The adapter normalizes a syntax declaration into `Declaration.Node`
    /// and `Declaration.IR`; everything downstream (analysis, emission,
    /// downstream derivation packages) is syntax-free. SwiftSyntax appears
    /// only here and in the compiler-plugin target.
    public struct SwiftSyntaxAdapter: Sendable {
        /// Creates an adapter.
        public init() {}
    }
}

extension Declaration.SwiftSyntaxAdapter {

    /// The normalized IR of a syntax declaration.
    public func intermediateRepresentation(
        from declaration: some SyntaxProtocol
    ) throws(Declaration.Derivation.Diagnostic) -> Declaration.IR {
        Declaration.IR(node: try node(from: declaration))
    }

    /// The normalized node of a syntax declaration.
    ///
    /// Structures and actors normalize their stored properties;
    /// enumerations normalize their cases. Any other declaration kind is
    /// rejected with the stable unsupported-kind diagnostic, and a
    /// stored property without an explicit type annotation is rejected
    /// as malformed.
    public func node(
        from declaration: some SyntaxProtocol
    ) throws(Declaration.Derivation.Diagnostic) -> Declaration.Node {
        if let structure = declaration.as(StructDeclSyntax.self) {
            return Declaration.Node(
                kind: .structure,
                name: Declaration.Node.Name(structure.name.trimmedDescription),
                members: try storedMembers(
                    of: structure.memberBlock,
                    declarationName: structure.name.trimmedDescription
                )
            )
        }
        if let actor = declaration.as(ActorDeclSyntax.self) {
            return Declaration.Node(
                kind: .actor,
                name: Declaration.Node.Name(actor.name.trimmedDescription),
                members: try storedMembers(
                    of: actor.memberBlock,
                    declarationName: actor.name.trimmedDescription
                )
            )
        }
        if let enumeration = declaration.as(EnumDeclSyntax.self) {
            return Declaration.Node(
                kind: .enumeration,
                name: Declaration.Node.Name(enumeration.name.trimmedDescription),
                members: caseMembers(of: enumeration.memberBlock)
            )
        }
        throw Declaration.Derivation.Diagnostic(
            code: .unsupportedDeclarationKind,
            subject: nil,
            detail: "only structures, enumerations and actors are supported by IR schema v1"
        )
    }

    // MARK: - Normalization

    private func storedMembers(
        of memberBlock: MemberBlockSyntax,
        declarationName: String
    ) throws(Declaration.Derivation.Diagnostic) -> [Declaration.Node.Member] {
        var members: [Declaration.Node.Member] = []
        for item in memberBlock.members {
            guard let variable = item.decl.as(VariableDeclSyntax.self) else {
                continue
            }
            for binding in variable.bindings {
                guard binding.accessorBlock == nil else {
                    continue
                }
                guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                    throw Declaration.Derivation.Diagnostic(
                        code: .malformedDeclaration,
                        subject: Declaration.Node.Name(declarationName),
                        detail: "stored property patterns must be plain identifiers"
                    )
                }
                guard let annotation = binding.typeAnnotation else {
                    throw Declaration.Derivation.Diagnostic(
                        code: .malformedDeclaration,
                        subject: Declaration.Node.Name(declarationName),
                        detail: "stored property '\(identifier.identifier.trimmedDescription)' requires an explicit type annotation"
                    )
                }
                members.append(
                    Declaration.Node.Member(
                        name: Declaration.Node.Name(identifier.identifier.trimmedDescription),
                        typeReference: Declaration.Node.Member.TypeReference(
                            annotation.type.trimmedDescription
                        ),
                        label: nil,
                        defaultValue: binding.initializer.map {
                            Declaration.Node.Member.DefaultValue($0.value.trimmedDescription)
                        },
                        mutability: variable.bindingSpecifier.tokenKind == .keyword(.let)
                            ? .constant
                            : .variable
                    )
                )
            }
        }
        return members
    }

    private func caseMembers(
        of memberBlock: MemberBlockSyntax
    ) -> [Declaration.Node.Member] {
        var members: [Declaration.Node.Member] = []
        for item in memberBlock.members {
            guard let enumerationCase = item.decl.as(EnumCaseDeclSyntax.self) else {
                continue
            }
            for element in enumerationCase.elements {
                members.append(
                    Declaration.Node.Member(
                        name: Declaration.Node.Name(element.name.trimmedDescription)
                    )
                )
            }
        }
        return members
    }
}
