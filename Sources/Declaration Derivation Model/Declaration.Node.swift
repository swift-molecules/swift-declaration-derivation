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
                /// The raw textual value.
                public let text: String

                /// Creates a value from its raw text.
                public init(_ text: String) {
                    self.text = text
                }
            }

            /// The normalized spelling of a member's type.
            public struct TypeReference: Hashable, Sendable {
                /// The raw textual value.
                public let text: String

                /// Creates a value from its raw text.
                public init(_ text: String) {
                    self.text = text
                }
            }

            /// The normalized spelling of a member's declared default value.
            ///
            /// Derived interfaces preserve it verbatim.
            public struct DefaultValue: Hashable, Sendable {
                /// The raw textual value.
                public let text: String

                /// Creates a value from its raw text.
                public init(_ text: String) {
                    self.text = text
                }
            }

            /// Whether a stored member may be assigned after its declaration.
            ///
            /// A `constant` member that also carries a default value is fully
            /// initialized at its declaration and may never be assigned
            /// again; a derived memberwise initializer must therefore omit
            /// it, exactly as Swift's own memberwise initializer does.
            public enum Mutability: Hashable, Sendable {
                case constant
                case variable
            }

            /// The member's name.
            public let name: Name
            /// `nil` for enumeration cases, which carry no stored type in
            /// schema v1.
            public let typeReference: TypeReference?
            /// `nil` when the label equals the member name.
            public let label: Label?
            /// The member's default value, when the source declares one.
            public let defaultValue: DefaultValue?
            /// Whether the member may be assigned after its declaration.
            public let mutability: Mutability

            /// Creates a normalized member from its facts.
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

        /// The declaration's kind.
        public let kind: Kind
        /// The declaration's name.
        public let name: Name
        /// Members in declaration order.
        ///
        /// Order is semantic: derived interfaces (for example a memberwise
        /// initializer) preserve it.
        public let members: [Member]

        /// Creates a normalized node from its kind, name and members.
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
        /// The raw textual value.
        public let text: String

        /// Creates a value from its raw text.
        public init(_ text: String) {
            self.text = text
        }
    }
}
