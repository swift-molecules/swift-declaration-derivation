public import Declaration_Derivation_Model

extension Declaration {

    public enum Derivation {}
}

extension Declaration.Derivation {

    public struct Diagnostic: Swift.Error, Hashable, Sendable, CustomStringConvertible {

        public let code: Code

        public let subject: Declaration.Node.Name?

        public let detail: String

        public init(code: Code, subject: Declaration.Node.Name? = nil, detail: String) {
            self.code = code
            self.subject = subject
            self.detail = detail
        }
    }
}

extension Declaration.Derivation.Diagnostic {

    public var description: String {
        if let subject {
            return "\(code.identifier) [\(subject.text)]: \(detail)"
        }
        return "\(code.identifier): \(detail)"
    }
}
