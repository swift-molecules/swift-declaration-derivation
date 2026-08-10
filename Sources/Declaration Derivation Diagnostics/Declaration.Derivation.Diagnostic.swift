// Declaration.Derivation.Diagnostic.swift

public import Declaration_Derivation_Model

extension Declaration {
    /// Namespace for the derivation machinery built on the normalized model:
    /// analysis, emission, diagnostics and the attached-macro expansion host.
    public enum Derivation {}
}

extension Declaration.Derivation {
    /// A stable, typed diagnostic of the derivation pipeline.
    ///
    /// Every rejection the pipeline can produce is one of these values. The
    /// rendered `description` is part of the contract: the same defect on
    /// the same input renders byte-identically on every run, so consumers
    /// and fixtures may assert on it.
    public struct Diagnostic: Swift.Error, Hashable, Sendable, CustomStringConvertible {
        /// The stable diagnostic code.
        public let code: Code
        /// The name of the declaration the diagnostic is about, when known.
        public let subject: Declaration.Node.Name?
        /// The stable human-readable detail.
        public let detail: String

        /// Creates a diagnostic from its code, optional subject and detail.
        public init(code: Code, subject: Declaration.Node.Name? = nil, detail: String) {
            self.code = code
            self.subject = subject
            self.detail = detail
        }
    }
}

extension Declaration.Derivation.Diagnostic {

    /// The stable rendered form: `code [subject]: detail`.
    public var description: String {
        if let subject {
            return "\(code.identifier) [\(subject.text)]: \(detail)"
        }
        return "\(code.identifier): \(detail)"
    }
}
