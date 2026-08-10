import Foundation

extension TX.D7A {
    struct Argument {
        let repository: URL
        let swift: URL
        let platform: String
        let configuration: String
        let samples: Int
        let evidence: URL

        init(_ values: [String]) throws(TX.D7A.Error) {
            var fields: [String: String] = [:]
            var index = 1
            while index < values.count {
                guard index + 1 < values.count else {
                    throw .argument("every argument requires a value")
                }
                fields[values[index]] = values[index + 1]
                index += 2
            }

            guard
                let repository = fields["--repository"],
                let swift = fields["--swift"],
                let platform = fields["--platform"],
                let configuration = fields["--configuration"],
                let rawSamples = fields["--samples"],
                let evidence = fields["--evidence"],
                let samples = Int(rawSamples),
                samples > 0
            else {
                throw .argument(
                    "required: --repository, --swift, --platform, --configuration, --samples, --evidence"
                )
            }

            guard ["Linux", "Windows"].contains(platform) else {
                throw .argument("platform must be Linux or Windows")
            }
            guard ["debug", "release"].contains(configuration) else {
                throw .argument("configuration must be debug or release")
            }

            self.repository = URL(fileURLWithPath: repository, isDirectory: true)
            self.swift = URL(fileURLWithPath: swift)
            self.platform = platform
            self.configuration = configuration
            self.samples = samples
            self.evidence = URL(fileURLWithPath: evidence, isDirectory: true)
        }
    }
}
