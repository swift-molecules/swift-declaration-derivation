import Declaration_Derivation

@DeclarationDerivation
struct Point {
    let x: Int
    let y: Int = 0
}

let point = Point(x: 7)
print(point.x + point.y)
