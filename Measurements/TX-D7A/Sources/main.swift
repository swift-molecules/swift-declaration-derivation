import Foundation

do throws(TX.D7A.Error) {
    try TX.D7A.run()
} catch {
    FileHandle.standardError.write(Data("TX-D7A ERROR \(error)\n".utf8))
    exit(1)
}
