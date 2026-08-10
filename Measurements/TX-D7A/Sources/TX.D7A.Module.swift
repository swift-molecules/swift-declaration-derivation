import Foundation

extension TX.D7A {
    enum Module {
        enum Metadata: Equatable {
            case readable(Double)
            case unreadable
        }

        enum Failure: Equatable, CustomStringConvertible {
            case beforeCleanNotEmpty
            case cleanEmpty
            case cleanMissing(String)
            case cleanExtra(String)
            case cleanMetadataUnreadable(String)
            case incrementalMissing(String)
            case incrementalExtra(String)
            case incrementalMetadataUnreadable(String)
            case incrementalMetadataChanged(String)

            var description: String {
                switch self {
                case .beforeCleanNotEmpty:
                    "source-module-before-clean-not-empty"
                case .cleanEmpty:
                    "source-module-clean-empty"
                case .cleanMissing(let name):
                    "source-module-clean-missing-\(name)"
                case .cleanExtra(let name):
                    "source-module-clean-extra-\(name)"
                case .cleanMetadataUnreadable(let name):
                    "source-module-clean-metadata-unreadable-\(name)"
                case .incrementalMissing(let name):
                    "source-module-incremental-missing-\(name)"
                case .incrementalExtra(let name):
                    "source-module-incremental-extra-\(name)"
                case .incrementalMetadataUnreadable(let name):
                    "source-module-incremental-metadata-unreadable-\(name)"
                case .incrementalMetadataChanged(let name):
                    "source-module-incremental-metadata-changed-\(name)"
                }
            }
        }

        typealias Observation = [String: Metadata]

        static let names = ["SwiftSyntax", "SwiftParser"]

        static func name(of artifact: URL) -> String? {
            guard artifact.pathExtension == "swiftmodule" else { return nil }
            let name = artifact.deletingPathExtension().lastPathComponent
            guard names.contains(name) else { return nil }
            return name
        }
    }
}

extension TX.D7A.Module {
    static func validate(
        beforeClean: Observation,
        clean: Observation,
        incremental: Observation
    ) -> Failure? {
        guard beforeClean.isEmpty else { return .beforeCleanNotEmpty }
        guard !clean.isEmpty else { return .cleanEmpty }

        for name in names {
            guard clean[name] != nil else { return .cleanMissing(name) }
        }
        if let name = extra(in: clean) {
            return .cleanExtra(name)
        }
        for name in names {
            guard case .readable = clean[name] else {
                return .cleanMetadataUnreadable(name)
            }
        }

        for name in names {
            guard incremental[name] != nil else { return .incrementalMissing(name) }
        }
        if let name = extra(in: incremental) {
            return .incrementalExtra(name)
        }
        for name in names {
            guard case .readable = incremental[name] else {
                return .incrementalMetadataUnreadable(name)
            }
        }
        for name in names {
            guard incremental[name] == clean[name] else {
                return .incrementalMetadataChanged(name)
            }
        }

        return nil
    }

    static func record(_ observation: Observation) -> [String: Any] {
        observation.mapValues { metadata in
            switch metadata {
            case .readable(let modificationDate): modificationDate
            case .unreadable: NSNull()
            }
        }
    }

    private static func extra(in observation: Observation) -> String? {
        observation.keys
            .filter { !names.contains($0) }
            .sorted()
            .first
    }
}
