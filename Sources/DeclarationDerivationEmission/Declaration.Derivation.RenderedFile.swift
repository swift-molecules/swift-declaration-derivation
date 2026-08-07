// Declaration.Derivation.RenderedFile.swift

public import DeclarationDerivationDiagnostics
public import DeclarationDerivationModel

extension Declaration.Derivation {
    /// A deterministic, self-describing emission result.
    ///
    /// The file name carries the generation-contract suffix so ownership is
    /// decidable from the name alone, and the contents open with the
    /// contract's provenance header.
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
        /// The name of a rendered file.
        public struct FileName: Hashable, Sendable {
            public let text: String

            public init(_ text: String) {
                self.text = text
            }
        }}
