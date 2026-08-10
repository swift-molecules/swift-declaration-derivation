import Foundation

extension TX.D7A {
    static func run() throws(TX.D7A.Error) {
        let argument = try TX.D7A.Argument(CommandLine.arguments)
        let environment = ProcessInfo.processInfo.environment
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("tx-d7a-\(UUID().uuidString)")
        do {
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
            try FileManager.default.createDirectory(at: argument.evidence, withIntermediateDirectories: true)
        } catch {
            throw .operation("could not create a measurement root or evidence directory")
        }
        defer {
            try? FileManager.default.removeItem(at: root)
        }

        let identityLog = root.appendingPathComponent("swift-version.log")
        _ = try command(
            argument.swift,
            arguments: ["--version"],
            directory: argument.repository,
            log: identityLog,
            evidence: argument.evidence,
            name: "swift --version"
        )
        let identity = try read(identityLog).trimmingCharacters(in: .whitespacesAndNewlines)
        try emit([
            "kind": "environment",
            "schemaVersion": 1,
            "subjectRevision": environment["TX_D7A_SUBJECT_SHA"] ?? "unmeasured",
            "runID": environment["GITHUB_RUN_ID"] ?? "unmeasured",
            "runAttempt": environment["GITHUB_RUN_ATTEMPT"] ?? "unmeasured",
            "runnerOS": environment["RUNNER_OS"] ?? "unmeasured",
            "runnerImage": environment["ImageVersion"] ?? environment["ImageOS"] ?? "unmeasured",
            "platform": argument.platform,
            "configuration": argument.configuration,
            "toolchain": identity,
            "processorCount": ProcessInfo.processInfo.processorCount,
            "physicalMemory": String(ProcessInfo.processInfo.physicalMemory),
            "samples": argument.samples,
        ])

        for sample in 1...argument.samples {
            let arms: [TX.D7A.Arm] = sample.isMultiple(of: 2) ? [.macro, .control] : [.control, .macro]
            for (order, arm) in arms.enumerated() {
                try measure(arm, sample: sample, order: order + 1, argument: argument, root: root)
            }
        }
    }
}
