public import Declaration_Derivation_Diagnostics
public import Declaration_Derivation_Model

extension Declaration.Derivation {

    public struct RenderedFile: Hashable, Sendable {

        public let fileName: FileName

        public let contents: String

        public init(fileName: FileName, contents: String) {
            self.fileName = fileName
            self.contents = contents
        }
    }
}

extension Declaration.Derivation.RenderedFile {

    public struct FileName: Hashable, Sendable {

        public let text: String

        public init(_ text: String) {
            self.text = text
        }
    }
}
