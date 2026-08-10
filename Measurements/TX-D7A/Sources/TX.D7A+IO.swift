import Foundation

extension TX.D7A {
    static func write(_ contents: String, to destination: URL) throws(TX.D7A.Error) {
        guard let data = contents.data(using: .utf8) else {
            throw .operation("could not encode temporary consumer source")
        }
        do {
            try data.write(to: destination, options: .atomic)
        } catch {
            throw .operation("could not write temporary consumer source")
        }
    }

    static func read(_ source: URL) throws(TX.D7A.Error) -> String {
        do {
            return try String(contentsOf: source, encoding: .utf8)
        } catch {
            throw .operation("could not read measurement output")
        }
    }

    static func copy(from source: URL, to destination: URL) throws(TX.D7A.Error) {
        let manager = FileManager.default
        do {
            try manager.createDirectory(at: destination, withIntermediateDirectories: true)
            for item in try manager.contentsOfDirectory(
                at: source,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) {
                if [".build", ".git", ".swiftpm"].contains(item.lastPathComponent) {
                    continue
                }
                let target = destination.appendingPathComponent(item.lastPathComponent)
                let directory = try item.resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true
                if directory {
                    try copy(from: item, to: target)
                } else {
                    try manager.copyItem(at: item, to: target)
                }
            }
        } catch let error as TX.D7A.Error {
            throw error
        } catch {
            throw .operation("could not create isolated measurement checkout")
        }
    }

    static func bytes(at root: URL) throws(TX.D7A.Error) -> Int64 {
        let manager = FileManager.default
        guard manager.fileExists(atPath: root.path) else { return 0 }
        guard
            let enumerator = manager.enumerator(
                at: root,
                includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey]
            )
        else {
            throw .operation("could not enumerate dependency checkout bytes")
        }

        var total: Int64 = 0
        for case let item as URL in enumerator {
            do {
                let values = try item.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
                if values.isRegularFile == true {
                    total += Int64(values.fileSize ?? 0)
                }
            } catch {
                throw .operation("could not read dependency checkout size")
            }
        }
        return total
    }

    static func count(at root: URL) throws(TX.D7A.Error) -> Int {
        guard FileManager.default.fileExists(atPath: root.path) else { return 0 }
        do {
            return try FileManager.default.contentsOfDirectory(atPath: root.path).count
        } catch {
            throw .operation("could not enumerate dependency checkouts")
        }
    }

    static func modules(
        at root: URL,
        named names: Set<String>
    ) throws(TX.D7A.Error) -> [String: Double] {
        let manager = FileManager.default
        guard manager.fileExists(atPath: root.path) else { return [:] }
        guard
            let enumerator = manager.enumerator(
                at: root,
                includingPropertiesForKeys: [.isRegularFileKey, .contentModificationDateKey]
            )
        else {
            throw .operation("could not enumerate source-built modules")
        }

        var modules: [String: Double] = [:]
        for case let item as URL in enumerator {
            if item.lastPathComponent == "checkouts" {
                enumerator.skipDescendants()
                continue
            }
            guard item.pathExtension == "swiftmodule" else { continue }
            let name = item.deletingPathExtension().lastPathComponent
            guard names.contains(name) else { continue }
            do {
                let values = try item.resourceValues(
                    forKeys: [.isRegularFileKey, .contentModificationDateKey]
                )

                guard
                    values.isRegularFile == true,
                    let modificationDate = values.contentModificationDate
                else {
                    throw TX.D7A.Error.operation("could not read source-built module metadata")
                }
                modules[name] = modificationDate.timeIntervalSinceReferenceDate
            } catch let error as TX.D7A.Error {
                throw error
            } catch {
                throw .operation("could not read source-built module metadata")
            }
        }
        return modules
    }
}
