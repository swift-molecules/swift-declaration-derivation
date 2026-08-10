import Foundation

extension TX.D7A {
    static func command(
        _ executable: URL,
        arguments: [String],
        directory: URL,
        log: URL,
        evidence: URL,
        name: String
    ) throws(TX.D7A.Error) -> (seconds: Double, status: Int32) {
        let manager = FileManager.default
        guard manager.createFile(atPath: log.path, contents: nil) else {
            throw .operation("could not create a measurement log")
        }

        let handle: FileHandle
        do {
            handle = try FileHandle(forWritingTo: log)
        } catch {
            throw .operation("could not open a measurement log")
        }
        defer {
            try? handle.close()
        }

        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        process.currentDirectoryURL = directory
        process.standardOutput = handle
        process.standardError = handle

        let clock = ContinuousClock()
        let start = clock.now
        do {
            try process.run()
        } catch {
            throw .operation("could not start \(name)")
        }
        process.waitUntilExit()
        let duration = start.duration(to: clock.now)
        let components = duration.components
        let seconds =
            Double(components.seconds) + Double(components.attoseconds) / 1_000_000_000_000_000_000

        guard process.terminationStatus == 0 else {
            try preserve(log, named: name, evidence: evidence)
            throw .process(name, process.terminationStatus)
        }
        return (seconds, process.terminationStatus)
    }

    static func swift(
        _ argument: TX.D7A.Argument,
        _ values: [String],
        directory: URL,
        log: URL,
        evidence: URL,
        name: String
    ) throws(TX.D7A.Error) -> (seconds: Double, status: Int32) {
        try command(
            argument.swift,
            arguments: values,
            directory: directory,
            log: log,
            evidence: evidence,
            name: name
        )
    }
}
