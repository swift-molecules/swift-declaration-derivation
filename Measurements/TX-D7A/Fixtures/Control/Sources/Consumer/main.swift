struct Point {
    let x: Int
    let y: Int

    init(x: Int, y: Int = 0) {
        self.x = x
        self.y = y
    }
}

let point = Point(x: 7)
print(point.x + point.y)
