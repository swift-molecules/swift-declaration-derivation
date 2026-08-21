public import Declaration_Derivation_Diagnostics
public import Declaration_Derivation_Model

extension Declaration.Derivation {

    public struct Analyzer: Sendable {

        public let rules: [Rule]

        public init(rules: [Rule] = Array(Rule.allCases)) {
            self.rules = rules
        }
    }
}

extension Declaration.Derivation.Analyzer {

    public func analyze(
        _ intermediateRepresentation: Declaration.IR
    ) throws(Declaration.Derivation.Diagnostic) -> Declaration.IR {
        for rule in rules {
            if let violation = rule.violation(in: intermediateRepresentation) {
                throw violation
            }
        }
        return intermediateRepresentation
    }
}
