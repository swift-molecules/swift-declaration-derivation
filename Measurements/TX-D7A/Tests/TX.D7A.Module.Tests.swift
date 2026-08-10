import Testing

@testable import TX_D7A_Measurement

extension TX.D7A.Module {
    @Suite struct Test {
        struct Control {
            let beforeClean: Observation
            let clean: Observation
            let incremental: Observation
            let expected: Failure?
        }

        static let artifacts: Observation = [
            "SwiftSyntax": .readable(1),
            "SwiftParser": .readable(2),
        ]

        static let controls = [
            Control(
                beforeClean: [:],
                clean: artifacts,
                incremental: artifacts,
                expected: nil
            ),
            Control(
                beforeClean: ["SwiftSyntax": .readable(0)],
                clean: artifacts,
                incremental: artifacts,
                expected: .beforeCleanNotEmpty
            ),
            Control(
                beforeClean: [:],
                clean: [:],
                incremental: [:],
                expected: .cleanEmpty
            ),
            Control(
                beforeClean: [:],
                clean: ["SwiftSyntax": .readable(1)],
                incremental: artifacts,
                expected: .cleanMissing("SwiftParser")
            ),
            Control(
                beforeClean: [:],
                clean: artifacts.merging(["SwiftDiagnostics": .readable(3)]) { _, replacement in replacement },
                incremental: artifacts,
                expected: .cleanExtra("SwiftDiagnostics")
            ),
            Control(
                beforeClean: [:],
                clean: ["SwiftSyntax": .unreadable, "SwiftParser": .readable(2)],
                incremental: artifacts,
                expected: .cleanMetadataUnreadable("SwiftSyntax")
            ),
            Control(
                beforeClean: [:],
                clean: artifacts,
                incremental: ["SwiftSyntax": .readable(1)],
                expected: .incrementalMissing("SwiftParser")
            ),
            Control(
                beforeClean: [:],
                clean: artifacts,
                incremental: artifacts.merging(["SwiftDiagnostics": .readable(3)]) { _, replacement in replacement },
                expected: .incrementalExtra("SwiftDiagnostics")
            ),
            Control(
                beforeClean: [:],
                clean: artifacts,
                incremental: ["SwiftSyntax": .unreadable, "SwiftParser": .readable(2)],
                expected: .incrementalMetadataUnreadable("SwiftSyntax")
            ),
            Control(
                beforeClean: [:],
                clean: artifacts,
                incremental: ["SwiftSyntax": .readable(3), "SwiftParser": .readable(2)],
                expected: .incrementalMetadataChanged("SwiftSyntax")
            ),
        ]

        @Test(arguments: controls)
        func `source module artifacts fail closed`(control: Control) {
            #expect(
                validate(
                    beforeClean: control.beforeClean,
                    clean: control.clean,
                    incremental: control.incremental
                ) == control.expected
            )
        }
    }
}
