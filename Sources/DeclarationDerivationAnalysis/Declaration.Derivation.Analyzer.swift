// Declaration.Derivation.Analyzer.swift

public import DeclarationDerivationDiagnostics
public import DeclarationDerivationModel

extension Declaration.Derivation {
    /// Validates a normalized IR against the analysis rules before any
    /// emission may consume it.
    ///
    /// The analyzer is deterministic: rules run in their declared order and
    /// the first violation is thrown as a stable, typed diagnostic.
    public struct Analyzer: Sendable {
        public let rules: [Rule]

        public init(rules: [Rule] = Array(Rule.allCases)) {
            self.rules = rules
        }
    }
}

extension Declaration.Derivation.Analyzer {

        /// Returns the IR unchanged when every rule holds; throws the first
        /// violation otherwise.
        public func analyze(
            _ intermediateRepresentation: Declaration.IR
        ) throws(Declaration.Derivation.Diagnostic) -> Declaration.IR {
            for rule in rules {
                if let violation = rule.violation(in: intermediateRepresentation) {
                    throw violation
                }
            }
            return intermediateRepresentation
        }}
