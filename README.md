# Declaration Derivation

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-molecules/swift-declaration-derivation/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-molecules/swift-declaration-derivation/actions/workflows/ci.yml)

`@DeclarationDerivation` derives a declaration's memberwise interface from a normalized declaration IR, under an explicit generation contract that records what the generator owns and which revision produced it.

---

## Key Features

- **Normalized declaration IR** — `Declaration.Node` and `Declaration.IR` describe a declaration independently of SwiftSyntax, so analysis and emission never parse.
- **Explicit generation contract** — `Declaration.GenerationContract` pairs a contract revision, an IR schema version and the exact package version pin, and every expansion carries that provenance.
- **Deterministic emission** — the same IR renders the same text; the fixture corpus is expanded twice in the test suite as the determinism control.
- **Stable diagnostics** — `Declaration.Derivation.Diagnostic.Code` is a fixed vocabulary (`malformed-declaration`, `unsupported-declaration-kind`, `empty-declaration-name`, `ambiguous-ownership`) that consumers can match against.
- **Contained SwiftSyntax boundary** — SwiftSyntax appears only in the adapter target and the compiler plugin; the model, analysis and emission cores are free of it.
- **No generated source under version control** — expansion happens at build time in the consumer.

---

## Quick Start

```swift
import Declaration_Derivation

@DeclarationDerivation
struct Point {
    let x: Int
    let y: Int
}

let point = Point(x: 1, y: 2)
```

The macro derives, as members of the attached declaration, the interface the
generation contract owns — a label- and default-preserving memberwise
initializer for structures and actors, a stable case-name accessor for
enumerations — plus the mandated provenance member.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-molecules/swift-declaration-derivation.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Declaration Derivation", package: "swift-declaration-derivation")
    ]
)
```

The package is pre-1.0 — depend on `branch: "main"` until `0.1.0` is tagged. Requires Swift 6.3 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the corresponding Linux / Windows toolchain).

---

## Architecture

| Product | Contents | When to import |
|---------|----------|----------------|
| `Declaration Derivation` | Umbrella — the `@DeclarationDerivation` macro and the `DeclarationDerivation` namespace | Most consumers |
| `Declaration Derivation Model` | `Declaration.Node`, `Declaration.IR`, `Declaration.GenerationContract` | Building or consuming the IR directly |
| `Declaration Derivation Analysis` | Analysis rules over the normalized IR | Validating an IR before emission |
| `Declaration Derivation Emission` | Deterministic rendering to `Declaration.Derivation.RenderedFile` | Rendering derived output |
| `Declaration Derivation Diagnostics` | `Declaration.Derivation.Diagnostic` and its stable codes | Matching on derivation failures |
| `Declaration SwiftSyntax Adapter` | The SwiftSyntax boundary that normalizes syntax into the IR | Feeding parsed syntax into the IR |
| `Declaration Derivation Macros` | The compiler plugin hosting attached-macro expansion | Build-time only |

The dependency direction is one way: the adapter and the plugin depend on the
model, analysis and emission cores, never the reverse.

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS 26         | Yes | Full support |
| Linux            | Yes | Full support |
| Windows          | Yes | Full support |
| iOS/tvOS/watchOS | —   | Supported    |
| Swift Embedded   | Yes | Model, analysis, emission and diagnostics only |

The macro plugin is a build-time compiler plugin and is not part of an Embedded
runtime image.

---

## Error Handling

Derivation failures surface as `Declaration.Derivation.Diagnostic`, carrying a
stable code, the subject declaration name and a human-readable detail:

```text
declaration.derivation.malformed-declaration
declaration.derivation.unsupported-declaration-kind
declaration.derivation.empty-declaration-name
declaration.derivation.ambiguous-ownership
```

Consumers match on the code; the detail text is diagnostic, not API.

---

## Related Packages

### Dependencies

- [`swift-syntax`](https://github.com/swiftlang/swift-syntax) — parsing and macro-expansion support, confined to the adapter target and the compiler plugin.

---

## Community

<!-- BEGIN: discussion -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
