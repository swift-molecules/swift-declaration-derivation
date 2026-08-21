public enum Declaration {}

extension Declaration {

    public struct Node: Hashable, Sendable {

        public struct Member: Hashable, Sendable {

            public struct Label: Hashable, Sendable {

                public let text: String

                public init(_ text: String) {
                    self.text = text
                }
            }

            public struct TypeReference: Hashable, Sendable {

                public let text: String

                public init(_ text: String) {
                    self.text = text
                }
            }

            public struct DefaultValue: Hashable, Sendable {

                public let text: String

                public init(_ text: String) {
                    self.text = text
                }
            }

            public enum Mutability: Hashable, Sendable {
                case constant
                case variable
            }

            public let name: Name

            public let typeReference: TypeReference?

            public let label: Label?

            public let defaultValue: DefaultValue?

            public let mutability: Mutability

            public init(
                name: Name,
                typeReference: TypeReference? = nil,
                label: Label? = nil,
                defaultValue: DefaultValue? = nil,
                mutability: Mutability = .variable
            ) {
                self.name = name
                self.typeReference = typeReference
                self.label = label
                self.defaultValue = defaultValue
                self.mutability = mutability
            }
        }

        public let kind: Kind

        public let name: Name

        public let members: [Member]

        public init(kind: Kind, name: Name, members: [Member]) {
            self.kind = kind
            self.name = name
            self.members = members
        }
    }
}

extension Declaration.Node {

    public enum Kind: String, Hashable, Sendable, CaseIterable {
        case structure
        case enumeration
        case actor
    }

    public struct Name: Hashable, Sendable {

        public let text: String

        public init(_ text: String) {
            self.text = text
        }
    }
}
