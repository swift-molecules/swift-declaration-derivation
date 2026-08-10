import Foundation

extension TX.D7A {
    static func preserve(
        _ log: URL,
        named name: String,
        evidence: URL
    ) throws(TX.D7A.Error) {
        let contents = try read(log)
        let environment = ProcessInfo.processInfo.environment
        let runtimeRoots = [
            environment["GITHUB_WORKSPACE"],
            environment["RUNNER_TEMP"],
            environment["RUNNER_WORKSPACE"],
        ]
        .compactMap { $0 }
        .map { URL(fileURLWithPath: $0, isDirectory: true) }
        let redacted = redact(
            contents,
            roots: [
                log.deletingLastPathComponent(),
                FileManager.default.homeDirectoryForCurrentUser,
            ] + runtimeRoots
        )
        let filename = name
            .lowercased()
            .map { $0.isLetter || $0.isNumber ? $0 : "-" }
        let destination = evidence.appendingPathComponent("\(String(filename))-failure.log")
        try write(redacted, to: destination)

        let diagnostic =
            redacted
            .split(whereSeparator: \Character.isNewline)
            .first { String($0).localizedCaseInsensitiveContains("error:") }
            ?? redacted.split(whereSeparator: \Character.isNewline).first
            ?? "no diagnostic was emitted"
        FileHandle.standardError.write(
            Data("TX-D7A FIRST DIAGNOSTIC [\(name)]: \(diagnostic)\n".utf8)
        )
        FileHandle.standardError.write(
            Data("TX-D7A FAILURE LOG: \(destination.lastPathComponent)\n".utf8)
        )
    }

    static func redact(_ contents: String, roots: [URL]) -> String {
        roots.reduce(contents) { result, candidate in
            result.replacingOccurrences(of: candidate.path, with: "<redacted-path>")
        }
    }
}
