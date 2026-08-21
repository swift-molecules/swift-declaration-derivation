public import Declaration_Derivation_Diagnostics
public import Declaration_Derivation_Model
public import SwiftSyntax

extension Declaration {

    public struct SwiftSyntaxAdapter: Sendable {

        public init() {}
    }
}

extension Declaration.SwiftSyntaxAdapter {

    public func intermediateRepresentation(
        from declaration: some SyntaxProtocol
    ) throws(Declaration.Derivation.Diagnostic) -> Declaration.IR {
        Declaration.IR(node: try node(from: declaration))
    }

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
                        detail: """
                            stored property '\(identifier.identifier.trimmedDescription)' \
                            requires an explicit type annotation
                            """
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
