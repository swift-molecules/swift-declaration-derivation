import Declaration_Derivation_Analysis
import Declaration_Derivation_Diagnostics
import Declaration_Derivation_Emission
import Declaration_Derivation_Model
import Declaration_SwiftSyntax_Adapter
import Testing

extension Declaration.Derivation.Emitter {
    @Suite struct Test {
        let emitter = Declaration.Derivation.Emitter(contract: FixtureCorpus.contract)
        let adapter = Declaration.SwiftSyntaxAdapter()

        @Test func `zero-member structure derives the empty initializer`() throws {
            let intermediateRepresentation = try adapter.intermediateRepresentation(
                from: FixtureCorpus.declaration(FixtureCorpus.zeroMemberStructure)
            )
            let rendered = try emitter.emit(intermediateRepresentation)
            #expect(rendered.fileName.text == "Empty+DeclarationDerivation.generated.swift")
            #expect(rendered.contents.contains("public init() {}"))
            #expect(rendered.contents.contains(FixtureCorpus.contract.provenance))
        }

        @Test func `defaults and member order are preserved`() throws {
            let intermediateRepresentation = try adapter.intermediateRepresentation(
                from: FixtureCorpus.declaration(FixtureCorpus.defaultPreservingStructure)
            )
            let members = try emitter.memberDeclarations(for: intermediateRepresentation)
            let initializer = try #require(members.first)
            #expect(initializer.contains("x: Int,"))
            #expect(initializer.contains("label: String = \"origin\""))
            let xPosition = try #require(initializer.firstRange(of: "x: Int"))
            let labelPosition = try #require(initializer.firstRange(of: "label: String"))
            #expect(xPosition.lowerBound < labelPosition.lowerBound)
        }

        @Test func `initialized constant members are omitted from the initializer`() throws {
            let intermediateRepresentation = try adapter.intermediateRepresentation(
                from: FixtureCorpus.declaration(FixtureCorpus.defaultPreservingStructure)
            )
            let members = try emitter.memberDeclarations(for: intermediateRepresentation)
            let initializer = try #require(members.first)
            #expect(!initializer.contains("y: Int"))
            #expect(!initializer.contains("self.y"))
        }

        @Test func `explicit argument labels are preserved`() throws {
            let node = Declaration.Node(
                kind: .structure,
                name: Declaration.Node.Name("Measure"),
                members: [
                    Declaration.Node.Member(
                        name: Declaration.Node.Name("magnitude"),
                        typeReference: Declaration.Node.Member.TypeReference("Double"),
                        label: Declaration.Node.Member.Label("of")
                    )
                ]
            )
            let members = try emitter.memberDeclarations(for: Declaration.IR(node: node))
            let initializer = try #require(members.first)
            #expect(initializer.contains("of magnitude: Double"))
        }

        @Test func `enumeration derives the stable case-name accessor`() throws {
            let intermediateRepresentation = try adapter.intermediateRepresentation(
                from: FixtureCorpus.declaration(FixtureCorpus.enumeration)
            )
            let members = try emitter.memberDeclarations(for: intermediateRepresentation)
            let accessor = try #require(members.first)
            #expect(accessor.contains("public var derivedCaseName: String {"))
            #expect(accessor.contains("case .north: \"north\""))
            #expect(accessor.contains("case .vector: \"vector\""))
        }

        @Test func `near miss - handwritten file names stay outside the contract`() {
            let contract = FixtureCorpus.contract
            #expect(contract.isGenerated(fileName: "Point+DeclarationDerivation.generated.swift"))
            #expect(!contract.isGenerated(fileName: "Point.swift"))
            #expect(!contract.isGenerated(fileName: "Point+Handwritten.swift"))
        }

        @Test func `unsupported kind is rejected with the stable diagnostic`() {
            do throws(Declaration.Derivation.Diagnostic) {
                _ = try adapter.intermediateRepresentation(
                    from: FixtureCorpus.declaration(FixtureCorpus.unsupportedClass)
                )
                Issue.record("expected an unsupported-declaration-kind diagnostic")
            } catch {
                #expect(error.code == .unsupportedDeclarationKind)
                #expect(
                    error.description
                        == "declaration.derivation.unsupported-declaration-kind: only structures, enumerations and actors are supported by IR schema v1"
                )
            }
        }
    }
}
