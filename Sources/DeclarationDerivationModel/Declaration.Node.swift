// Declaration.Node.swift

/// Namespace for the normalized declaration model.
///
/// `Declaration` owns the derivation family's shared vocabulary: the
/// normalized node (`Declaration.Node`), the versioned intermediate
/// representation (`Declaration.IR`) and the generation contract
/// (`Declaration.GenerationContract`). Downstream derivation packages
/// (coproduct derivation, witness derivation) consume this vocabulary and
/// never re-derive it from syntax themselves.
public enum Declaration {}

extension Declaration {
    /// A normalized, syntax-independent representation of a single Swift
    /// declaration.
    ///
    /// A node carries exactly the facts derivation needs — declaration kind,
    /// declaration name and the ordered member list — and nothing the source
    /// syntax happened to include (trivia, attributes outside the generation
    /// contract, formatting). Two source spellings of the same declaration
    /// normalize to equal nodes; equality is therefore the model's
    /// determinism primitive.
    public struct Node: Hashable, Sendable {

        /// A normalized member of a declaration: a stored property of a
        /// structure or actor, or a case of an enumeration.
        public struct Member: Hashable, Sendable {
            /// An explicit argument label a derived interface must preserve.
            public struct Label: Hashable, Sendable {
                public let text: String

                public init(_ text: String) {
                    self.text = text
                }
            }

            /// The normalized spelling of a member's type.
            public struct TypeReference: Hashable, Sendable {
                public let text: String

                public init(_ text: String) {
                    self.text = text
                }
            }

            /// The normalized spelling of a member's default value, when the
            /// source declares one. Derived interfaces preserve it verbatim.
            public struct DefaultValue: Hashable, Sendable {
                public let text: String

                public init(_ text: String) {
                    self.text = text
                }
            }

            public let name: Name
            /// `nil` for enumeration cases, which carry no stored type in
            /// schema v1.
            public let typeReference: TypeReference?
            /// `nil` when the label equals the member name.
            public let label: Label?
            public let defaultValue: DefaultValue?

            public init(
                name: Name,
                typeReference: TypeReference? = nil,
                label: Label? = nil,
                defaultValue: DefaultValue? = nil
            ) {
                self.name = name
                self.typeReference = typeReference
                self.label = label
                self.defaultValue = defaultValue
            }
        }

        public let kind: Kind
        public let name: Name
        /// Members in declaration order. Order is semantic: derived
        /// interfaces (for example a memberwise initializer) preserve it.
        public let members: [Member]

        public init(kind: Kind, name: Name, members: [Member]) {
            self.kind = kind
            self.name = name
            self.members = members
        }
    }
}

extension Declaration.Node {
        /// The supported declaration kinds of IR schema v1.
        ///
        /// Kinds outside this enumeration are rejected at the adapter
        /// boundary with the stable
        /// `declaration.derivation.unsupported-declaration-kind` diagnostic.
        public enum Kind: String, Hashable, Sendable, CaseIterable {
            case structure
            case enumeration
            case actor
        }

        /// The name of a declaration or of one of its members.
        public struct Name: Hashable, Sendable {
            public let text: String

            public init(_ text: String) {
                self.text = text
            }
        }}
