extension Declaration {

    public struct IR: Hashable, Sendable {

        public struct SchemaVersion: Hashable, Sendable {

            public let major: Int

            public init(major: Int) {
                self.major = major
            }

            public static let version1 = SchemaVersion(major: 1)

            public var identifier: String {
                "v\(major)"
            }
        }

        public let schemaVersion: SchemaVersion

        public let node: Node

        public init(schemaVersion: SchemaVersion = .version1, node: Node) {
            self.schemaVersion = schemaVersion
            self.node = node
        }
    }
}
