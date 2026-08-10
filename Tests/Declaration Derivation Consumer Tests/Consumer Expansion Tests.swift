// Consumer Expansion Tests.swift

import Declaration_Derivation
import Testing

// MARK: - Consumer-integration control
//
// This suite is the control that the package's other test targets are
// structurally incapable of being: it depends on nothing but the target
// behind the "Declaration Derivation" library product, so it compiles
// against exactly the surface an external consumer receives. Expansion
// therefore proves the product carries its own compiler plugin. An
// expansion test that also depends on DeclarationDerivationMacros — or one
// that supplies the macro mapping itself through `macroSpecs:` — cannot
// detect a missing or unresolvable macro declaration.

@DeclarationDerivation
private struct Point {
    let x: Int
    let y: Int = 0
    var label: String = "origin"
}

@DeclarationDerivation
private enum Direction {
    case north
    case south
}

@DeclarationDerivation
private actor Counter {
    var count: Int = 0
}

private let expectedProvenance =
    "contract-revision=1;ir-schema=v1;package-version-pin=swift-primitives/swift-declaration-derivation@main"

extension DeclarationDerivation {
    @Suite struct Test {

        /// The attribute is writable by a consumer of the library product alone
        /// and derives the label- and default-preserving memberwise initializer.
        @Test func `structure derives a default preserving memberwise initializer`() {
            let point = Point(x: 7)
            #expect(point.x == 7)
            #expect(point.label == "origin")
            let labelled = Point(x: 1, label: "corner")
            #expect(labelled.label == "corner")
        }

        /// The defect shape of the reopened TX-D1: an initialized `let`
        /// member must be omitted from the derived initializer or the
        /// expansion does not compile at a consumer site at all.
        @Test func `initialized constant members are preserved, not reassigned`() {
            let point = Point(x: 7)
            #expect(point.y == 0)
        }

        /// Enumerations derive the stable case-name accessor.
        @Test func `enumeration derives a stable case name accessor`() {
            #expect(Direction.north.derivedCaseName == "north")
            #expect(Direction.south.derivedCaseName == "south")
        }

        /// Actors derive under the same contract as structures.
        @Test func `actor derives a memberwise initializer`() async {
            let counter = Counter(count: 3)
            #expect(await counter.count == 3)
        }

        /// Every expansion carries the generation contract's provenance.
        @Test func `expansions carry provenance`() {
            #expect(Point.declarationDerivationProvenance == expectedProvenance)
            #expect(Direction.declarationDerivationProvenance == expectedProvenance)
            #expect(Counter.declarationDerivationProvenance == expectedProvenance)
        }
    }
}
