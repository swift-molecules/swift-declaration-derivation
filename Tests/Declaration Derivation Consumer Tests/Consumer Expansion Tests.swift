import Declaration_Derivation
import Testing

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

        @Test func `structure derives a default preserving memberwise initializer`() {
            let point = Point(x: 7)
            #expect(point.x == 7)
            #expect(point.label == "origin")
            let labelled = Point(x: 1, label: "corner")
            #expect(labelled.label == "corner")
        }

        @Test func `initialized constant members are preserved, not reassigned`() {
            let point = Point(x: 7)
            #expect(point.y == 0)
        }

        @Test func `enumeration derives a stable case name accessor`() {
            #expect(Direction.north.derivedCaseName == "north")
            #expect(Direction.south.derivedCaseName == "south")
        }

        @Test func `actor derives a memberwise initializer`() async {
            let counter = Counter(count: 3)
            #expect(await counter.count == 3)
        }

        @Test func `expansions carry provenance`() {
            #expect(Point.declarationDerivationProvenance == expectedProvenance)
            #expect(Direction.declarationDerivationProvenance == expectedProvenance)
            #expect(Counter.declarationDerivationProvenance == expectedProvenance)
        }
    }
}
