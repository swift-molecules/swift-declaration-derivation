extension Declaration {

    public struct GenerationContract: Hashable, Sendable {

        public let revision: Revision

        public let schemaVersion: IR.SchemaVersion

        public let packageVersionPin: PackageVersionPin

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

    public struct Revision: Hashable, Sendable {

        public let text: String

        public init(_ text: String) {
            self.text = text
        }
    }

    public struct PackageVersionPin: Hashable, Sendable {

        public let text: String

        public init(_ text: String) {
            self.text = text
        }
    }

    public static let generatedFileNameSuffix = "+DeclarationDerivation.generated.swift"

    public func isGenerated(fileName: String) -> Bool {
        fileName.hasSuffix(Self.generatedFileNameSuffix)
    }

    public func generatedFileName(for name: Declaration.Node.Name) -> String {
        name.text + Self.generatedFileNameSuffix
    }

    public func covers(_ node: Declaration.Node) -> Bool {
        Declaration.Node.Kind.allCases.contains(node.kind)
    }

    public var provenance: String {
        "contract-revision=\(revision.text);ir-schema=\(schemaVersion.identifier);package-version-pin=\(packageVersionPin.text)"
    }
}
