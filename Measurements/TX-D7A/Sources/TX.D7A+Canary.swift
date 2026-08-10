import Foundation

extension TX.D7A {
    @inline(never)
    static func canary(seed: UInt64) -> (seconds: Double, sink: UInt64) {
        let clock = ContinuousClock()
        let start = clock.now
        var value = seed
        for index in 0..<50_000_000 {
            value = (value &* 2_862_933_555_777_941_757) &+ UInt64(index)
        }
        let components = start.duration(to: clock.now).components
        let seconds =
            Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000
        return (seconds, value)
    }
}
