# TX-D7 classification

Verdict: **UNFAVORABLE**.

The accepted gate requires macOS, Linux, and Windows measurements with and without prebuilt SwiftSyntax. SwiftPM enables its experimental prebuilt path by default. In the exact-head full-tier run, macOS selected and downloaded `MacroSupport`, while Linux and Windows resolved the same SwiftSyntax version and compiled it from source. The required prebuilt-enabled arm therefore exists on only one of three named platforms.

| Platform | Enabled prebuilt selected | Source-build control | Clean build |
| --- | ---: | --- | ---: |
| macOS | yes | zero SwiftSyntax source-compile lines | 78.04 s |
| Linux | no | SwiftSyntax and SwiftParser build-progress modules | 513.10 s |
| Windows | no | 189 SwiftSyntax/SwiftParser compile lines | 209.07 s |

The seconds are not compared across platforms: macOS and Windows used debug builds, Linux used release, and runner environments differ. They identify the observed arms only. No within-platform prebuilt/source ratio is reported because two platforms cannot supply the required prebuilt arm and the transaction's stop rule fires first.

Controls:

- Positive: the macOS job records a successful prebuilt download and no SwiftSyntax source compilation under the same default-enabled SwiftPM mechanism.
- Absence/closure: Linux and Windows both resolve `swift-syntax` 602.0.0, then positively record SwiftSyntax/SwiftParser source compilation rather than merely omitting a download line.
- Host availability: every named platform builds and tests the attached macro successfully; the failure is economics/prebuilt coverage, not macro-host absence.
- Stop: once the all-platform prebuilt arm failed, dependency-closure, governance-advance, Embedded-closure, incremental, and repeated-process measurements were deliberately not enumerated. They cannot turn the required 1/3 coverage into 3/3.

This fires `STOP-D7-MACRO-ECONOMICS`. TX-VM1, TX-VM2, TX-VM3, TX-VG1, TX-VG2, TX-VG3, TX-VS1, TX-VS2, and TX-VS3 remain blocked. The result returns to [swift-institute/.github#85](https://github.com/swift-institute/.github/issues/85) for a principal delivery-economics ruling; it is not a waiver and does not authorize an offline driver or committed generated source.

Exact evidence: [full-tier run 31383906743](https://github.com/swift-primitives/swift-declaration-derivation/actions/runs/31383906743), subject `f195606aebbe7749b7ccde86129de550fc4b9a4f`, universal workflow `swift-ci.yml@main` resolved to `4eb5e080688dfca88bd99d09fdba6077c360534e`.
