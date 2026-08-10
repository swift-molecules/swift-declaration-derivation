import Foundation

extension TX.D7A {
    static func measure(
        _ arm: TX.D7A.Arm,
        sample: Int,
        order: Int,
        argument: TX.D7A.Argument,
        root: URL
    ) throws(TX.D7A.Error) {
        let manager = FileManager.default
        let sampleRoot = root.appendingPathComponent("\(sample)-\(arm.rawValue)")
        let checkout = sampleRoot.appendingPathComponent("checkout")
        let scratch = sampleRoot.appendingPathComponent("scratch")
        try copy(from: argument.repository, to: checkout)

        let fixture =
            checkout
            .appendingPathComponent("Measurements/TX-D7A/Fixtures")
            .appendingPathComponent(arm == .macro ? "Macro" : "Control")
        let source = fixture.appendingPathComponent("Sources/Consumer/main.swift")

        let resolveLog = sampleRoot.appendingPathComponent("resolve.log")
        let resolve = try swift(
            argument,
            ["package", "resolve", "--scratch-path", scratch.path],
            directory: fixture,
            log: resolveLog,
            evidence: argument.evidence,
            name: "swift package resolve"
        )

        var buildArguments = [
            "build", "-c", argument.configuration,
            "--scratch-path", scratch.path,
            "--disable-experimental-prebuilts",
        ]
        if argument.platform == "Windows" {
            buildArguments += ["--build-system", "native"]
        }

        let before = canary(seed: UInt64(sample * 10 + order))
        let sourceModuleNames: Set<String> = ["SwiftSyntax", "SwiftParser"]
        let sourceBeforeClean = try modules(at: scratch, named: sourceModuleNames)
        let cleanLog = sampleRoot.appendingPathComponent("clean.log")
        let clean = try swift(
            argument,
            buildArguments,
            directory: fixture,
            log: cleanLog,
            evidence: argument.evidence,
            name: "swift build clean sample"
        )
        let sourceClean = try modules(at: scratch, named: sourceModuleNames)

        let original = try read(source)
        try write(original + "\n// TX-D7A incremental sample \(sample)\n", to: source)

        let incrementalLog = sampleRoot.appendingPathComponent("incremental.log")
        let incremental = try swift(
            argument,
            buildArguments,
            directory: fixture,
            log: incrementalLog,
            evidence: argument.evidence,
            name: "swift build incremental sample"
        )
        let sourceIncremental = try modules(at: scratch, named: sourceModuleNames)
        let after = canary(seed: UInt64(sample * 10 + order))

        var pathArguments = [
            "build", "-c", argument.configuration,
            "--show-bin-path", "--scratch-path", scratch.path,
            "--disable-experimental-prebuilts",
        ]
        if argument.platform == "Windows" {
            pathArguments += ["--build-system", "native"]
        }
        let pathLog = sampleRoot.appendingPathComponent("path.log")
        _ = try swift(
            argument,
            pathArguments,
            directory: fixture,
            log: pathLog,
            evidence: argument.evidence,
            name: "swift build show bin path"
        )
        guard let path = try read(pathLog).split(whereSeparator: \Character.isNewline).last else {
            throw .operation("swift build did not report a binary path")
        }
        let executable = URL(fileURLWithPath: String(path))
            .appendingPathComponent(argument.platform == "Windows" ? "Consumer.exe" : "Consumer")
        let runLog = sampleRoot.appendingPathComponent("run.log")
        _ = try command(
            executable,
            arguments: [],
            directory: fixture,
            log: runLog,
            evidence: argument.evidence,
            name: "consumer executable"
        )

        let cleanContents = try read(cleanLog)
        let output = try read(runLog).trimmingCharacters(in: .whitespacesAndNewlines)
        let prebuiltNames = ["download.swift.org/prebuilts", "MacroSupport.zip"]
        let prebuiltClean = lines(in: cleanContents, matching: prebuiltNames)
        let dependencies = try pins(at: fixture)
        let checkouts = try count(at: scratch.appendingPathComponent("checkouts"))
        let checkoutBytes = try bytes(at: scratch.appendingPathComponent("checkouts"))

        let closure =
            arm == .macro
            ? sourceBeforeClean.isEmpty
                && Set(sourceClean.keys) == sourceModuleNames
                && sourceIncremental == sourceClean
                && dependencies == 1
            : sourceBeforeClean.isEmpty
                && sourceClean.isEmpty
                && sourceIncremental.isEmpty
                && dependencies == 0
                && checkouts == 0
        let valid = output == "7" && prebuiltClean == 0 && closure

        let environment = ProcessInfo.processInfo.environment
        try emit([
            "kind": "sample",
            "schemaVersion": 2,
            "subjectRevision": environment["TX_D7A_SUBJECT_SHA"] ?? "unmeasured",
            "runID": environment["GITHUB_RUN_ID"] ?? "unmeasured",
            "runAttempt": environment["GITHUB_RUN_ATTEMPT"] ?? "unmeasured",
            "runnerImage": environment["ImageVersion"] ?? environment["ImageOS"] ?? "unmeasured",
            "platform": argument.platform,
            "configuration": argument.configuration,
            "sample": sample,
            "order": order,
            "arm": arm.rawValue,
            "commands": [
                "swift package resolve --scratch-path <fresh>",
                "swift build -c \(argument.configuration) --scratch-path <fresh> --disable-experimental-prebuilts",
                "edit temporary consumer source",
                "swift build -c \(argument.configuration) --scratch-path <same> --disable-experimental-prebuilts",
                "run Consumer",
            ],
            "resolveSeconds": resolve.seconds,
            "cleanSeconds": clean.seconds,
            "incrementalSeconds": incremental.seconds,
            "externalPackages": dependencies,
            "checkouts": checkouts,
            "checkoutBytes": checkoutBytes,
            "sourceModulesBeforeClean": sourceBeforeClean,
            "sourceModulesClean": sourceClean,
            "sourceModulesIncremental": sourceIncremental,
            "prebuiltLinesClean": prebuiltClean,
            "consumerOutput": output,
            "canaryBeforeSeconds": before.seconds,
            "canaryAfterSeconds": after.seconds,
            "canarySink": String(after.sink),
            "valid": valid,
        ])

        guard valid else {
            throw .control("\(argument.platform) sample \(sample) \(arm.rawValue) failed a validity control")
        }

        do {
            try manager.removeItem(at: sampleRoot)
        } catch {
            throw .operation("could not retire an isolated measurement sample")
        }
    }
}
