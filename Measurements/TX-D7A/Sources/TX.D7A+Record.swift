import Foundation

extension TX.D7A {
    static func emit(_ record: [String: Any]) throws(TX.D7A.Error) {
        let data: Data
        do {
            data = try JSONSerialization.data(
                withJSONObject: record,
                options: [.sortedKeys, .withoutEscapingSlashes]
            )
        } catch {
            throw .operation("could not encode a measurement record")
        }
        guard let line = String(data: data, encoding: .utf8) else {
            throw .operation("could not render a measurement record")
        }
        print("TX-D7A \(line)")
    }

    static func pins(at fixture: URL) throws(TX.D7A.Error) -> Int {
        let resolved = fixture.appendingPathComponent("Package.resolved")
        guard FileManager.default.fileExists(atPath: resolved.path) else { return 0 }
        let data: Data
        do {
            data = try Data(contentsOf: resolved)
        } catch {
            throw .operation("could not read resolved dependency closure")
        }
        let object: Any
        do {
            object = try JSONSerialization.jsonObject(with: data)
        } catch {
            throw .operation("could not decode resolved dependency closure")
        }
        guard
            let root = object as? [String: Any],
            let pins = root["pins"] as? [[String: Any]]
        else {
            throw .operation("Package.resolved did not contain a pins array")
        }
        return pins.count
    }

    static func lines(in contents: String, matching names: [String]) -> Int {
        contents.split(whereSeparator: \Character.isNewline).count { line in
            let text = String(line)
            return names.contains { text.contains($0) }
        }
    }
}
