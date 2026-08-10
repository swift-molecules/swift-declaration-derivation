// Declaration.Derivation.RenderedFile.swift

public import Declaration_Derivation_Diagnostics
public import Declaration_Derivation_Model

extension Declaration.Derivation {
    /// A deterministic, self-describing emission result.
    ///
    /// The file name carries the generation-contract suffix so ownership is
    /// decidable from the name alone, and the contents open with the
    /// contract's provenance header.
    public struct RenderedFile: Hashable, Sendable {

        /// The contract-owned name of the rendered file.
        public let fileName: FileName
        /// The complete rendered contents.
        public let contents: String

        /// Creates a rendered file from its name and contents.
        public init(fileName: FileName, contents: String) {
            self.fileName = fileName
            self.contents = contents
        }
    }
}

extension Declaration.Derivation.RenderedFile {
    /// The name of a rendered file.
    public struct FileName: Hashable, Sendable {
        /// The raw textual value.
        public let text: String

        /// Creates a value from its raw text.
        public init(_ text: String) {
            self.text = text
        }
    }
}
