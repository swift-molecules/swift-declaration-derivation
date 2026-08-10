// Declaration.GenerationContract.swift

extension Declaration {
    /// The contract between a generator and its consumers.
    ///
    /// The contract answers two questions deterministically: which output a
    /// generator owns (so handwritten declarations outside the contract are
    /// never touched) and which provenance every generated expansion or file
    /// must carry (contract revision, IR schema version and the exact
    /// package version pin of the generator).
    public struct GenerationContract: Hashable, Sendable {

        /// The revision of the generation contract itself.
        public let revision: Revision
        /// The IR schema version the contract generates under.
        public let schemaVersion: IR.SchemaVersion
        /// The exact package version pin of the generator.
        public let packageVersionPin: PackageVersionPin

        /// Creates a contract from its revision, schema version and pin.
        public init(
            revision: Revision,
            schemaVersion: IR.SchemaVersion,
            packageVersionPin: PackageVersionPin
        ) {
            self.revision = revision
            self.schemaVersion = schemaVersion
            self.packageVersionPin = packageVersionPin
        }
    }
}

extension Declaration.GenerationContract {
    /// The revision of the generation contract itself.
    public struct Revision: Hashable, Sendable {
        /// The raw textual value.
        public let text: String

        /// Creates a value from its raw text.
        public init(_ text: String) {
            self.text = text
        }
    }

    /// The exact package version pin of the generator that produced an
    /// output.
    ///
    /// Consumers admit expansion-behavior exceptions only when their
    /// resolved pin matches the receipt's pin.
    public struct PackageVersionPin: Hashable, Sendable {
        /// The raw textual value.
        public let text: String

        /// Creates a value from its raw text.
        public init(_ text: String) {
            self.text = text
        }
    }

    /// The file-name suffix that marks a rendered file as owned by this
    /// generation contract.
    ///
    /// Anything without the suffix is handwritten and outside the contract.
    public static let generatedFileNameSuffix = "+DeclarationDerivation.generated.swift"

    /// Whether a file name identifies output owned by the generation
    /// contract.
    public func isGenerated(fileName: String) -> Bool {
        fileName.hasSuffix(Self.generatedFileNameSuffix)
    }

    /// The deterministic file name for the generated output of a node.
    public func generatedFileName(for name: Declaration.Node.Name) -> String {
        name.text + Self.generatedFileNameSuffix
    }

    /// Whether the contract covers a node — that is, whether generation
    /// owns output for it under IR schema v1.
    public func covers(_ node: Declaration.Node) -> Bool {
        Declaration.Node.Kind.allCases.contains(node.kind)
    }

    /// The provenance record every generated expansion and rendered file
    /// carries: contract revision, IR schema version and package pin.
    public var provenance: String {
        "contract-revision=\(revision.text);ir-schema=\(schemaVersion.identifier);package-version-pin=\(packageVersionPin.text)"
    }
}
