# TX-D7A source-built attached-macro economics

Classification: **FAVORABLE within the bounded source-built delivery budget.**

This is a classification of the authorized Linux and Windows external-consumer measurement only. It does not waive the source-built delivery model, authorize offline or build-tool generation, or authorize committed generated source. TX-VM1–3, TX-VG1–3, and TX-VS1–3 remain blocked pending a later principal ruling.

## Validity

Two independently triggered hosted runs succeeded: [31430610265](https://github.com/swift-primitives/swift-declaration-derivation/actions/runs/31430610265) at f3de14934c81165379b8a4a1d6b4ea4e382a3c1e, and [31433263352](https://github.com/swift-primitives/swift-declaration-derivation/actions/runs/31433263352) at zero-delta c36e7dd0771570e8e920be60353075b2914c06e9. Each run supplies two alternating-order pairs on each platform.

Every accepted record identifies the hosted runner image, Swift 6.4 toolchain, platform/configuration, arm, order, subject revision, commands, exit-valid result, and raw durations. Both arms return 7. Every macro record uses --disable-experimental-prebuilts, records no prebuilt line, and records both SwiftSyntax and SwiftParser source-module outputs during the clean build; the same source-module observations remain present after the consumer-only edit. Every control has zero SwiftSyntax/SwiftParser outputs, zero external packages, and zero checkouts. The drift canary was present before and after every sample without a material change.

## Combined four-sample result

For every even-sized vector, median = (sorted[n / 2 - 1] + sorted[n / 2]) / 2. A paired surcharge is macro - control for the same run and sample. Cross-run spread is (larger run median - smaller run median) / smaller run median.

| Platform | Clean macro median | Incremental macro median | Incremental paired surcharge median | Resolve surcharge median | Clean spread | Incremental spread | Observed closure |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Linux (release) | 494.091 s | 2.206 s | 1.078 s | 4.086 s | 3.001% | 1.189% | 1 external package, 1 checkout, 10,110,789 bytes |
| Windows (debug) | 150.750 s | 4.304 s | 2.733 s | 15.124 s | 2.276% | 13.848% | 1 external package, 1 checkout, 10,404,514 bytes |

The raw vector is [matrix.json](matrix.json). Linux and Windows timings are evaluated only within their stated platform and configuration.

## Budget outcome

- Linux clean macro median: 494.091 s ≤ 600 s.
- Windows clean macro median: 150.750 s ≤ 300 s.
- Consumer-edit incremental medians: 2.206 s and 4.304 s ≤ 30 s.
- Consumer-edit paired-surcharge medians: 1.078 s and 2.733 s ≤ 20 s.
- Dependency closure: exactly one external package beyond the control, and resolve-surcharge medians of 4.086 s and 15.124 s ≤ 120 s.
- Stability: clean spreads of 3.001% and 2.276% ≤ 20%; incremental spreads of 1.189% and 13.848% ≤ 35%.

Checkout bytes are reported observed cost only, as the accepted contract assigns them no favorable threshold.

The accepted contract therefore classifies this authorized scope as favorable. It proves only the bounded source-built, external-consumer clean, consumer-edit incremental, resolve, and dependency-closure economics above. It does not compare configurations or platforms, establish vendor implementation economics, or supersede any blocked lane.
