// Analyzer Tests.swift

import DeclarationDerivationAnalysis
import DeclarationDerivationDiagnostics
import DeclarationDerivationModel
import Testing

extension Declaration.Derivation.Analyzer {
    @Suite struct Test {
        @Test func `valid IR passes unchanged`() throws {
            let node = Declaration.Node(
                kind: .structure,
                name: Declaration.Node.Name("Point"),
                members: [
                    Declaration.Node.Member(
                        name: Declaration.Node.Name("x"),
                        typeReference: Declaration.Node.Member.TypeReference("Int")
                    )
                ]
            )
            let intermediateRepresentation = Declaration.IR(node: node)
            let analyzed = try Declaration.Derivation.Analyzer().analyze(intermediateRepresentation)
            #expect(analyzed == intermediateRepresentation)
        }

        @Test func `duplicate member names are ambiguous ownership`() {
            let node = Declaration.Node(
                kind: .structure,
                name: Declaration.Node.Name("Twice"),
                members: [
                    Declaration.Node.Member(
                        name: Declaration.Node.Name("value"),
                        typeReference: Declaration.Node.Member.TypeReference("Int")
                    ),
                    Declaration.Node.Member(
                        name: Declaration.Node.Name("value"),
                        typeReference: Declaration.Node.Member.TypeReference("String")
                    ),
                ]
            )
            do throws(Declaration.Derivation.Diagnostic) {
                _ = try Declaration.Derivation.Analyzer().analyze(Declaration.IR(node: node))
                Issue.record("expected an ambiguous-ownership diagnostic")
            } catch {
                #expect(error.code == .ambiguousOwnership)
                #expect(
                    error.description
                        == "declaration.derivation.ambiguous-ownership [Twice]: member 'value' is declared more than once; ownership of the derived interface is ambiguous"
                )
            }
        }

        @Test func `empty declaration name is rejected`() {
            let node = Declaration.Node(
                kind: .structure,
                name: Declaration.Node.Name(""),
                members: []
            )
            do throws(Declaration.Derivation.Diagnostic) {
                _ = try Declaration.Derivation.Analyzer().analyze(Declaration.IR(node: node))
                Issue.record("expected an empty-declaration-name diagnostic")
            } catch {
                #expect(error.code == .emptyDeclarationName)
            }
        }
    }
}
