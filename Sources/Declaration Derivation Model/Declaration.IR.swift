// Declaration.IR.swift

extension Declaration {
    /// The versioned intermediate representation of a declaration.
    ///
    /// The IR is the derivation family's exchange format: adapters produce
    /// it, analysis validates it, emitters and downstream derivation
    /// packages consume it. The schema version travels with every value so
    /// a consumer can reject an IR it does not understand instead of
    /// misreading it.
    public struct IR: Hashable, Sendable {
        /// The IR schema version.
        ///
        /// Schema v1 covers structures, enumerations and actors with
        /// name/type/label/default-preserving members.
        public struct SchemaVersion: Hashable, Sendable {
            /// The major schema version number.
            public let major: Int

            /// Creates a schema version from its major number.
            public init(major: Int) {
                self.major = major
            }

            /// Schema v1 — the initial declaration-derivation IR schema.
            public static let version1 = SchemaVersion(major: 1)

            /// The stable textual identifier, for example `"v1"`.
            public var identifier: String {
                "v\(major)"
            }
        }

        /// The schema version this IR value conforms to.
        public let schemaVersion: SchemaVersion
        /// The normalized declaration node.
        public let node: Node

        /// Creates an IR value from a node under a schema version.
        public init(schemaVersion: SchemaVersion = .version1, node: Node) {
            self.schemaVersion = schemaVersion
            self.node = node
        }
    }
}
