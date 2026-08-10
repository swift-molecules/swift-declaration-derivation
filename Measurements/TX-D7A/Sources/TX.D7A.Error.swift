extension TX.D7A {
    enum Error: Swift.Error, CustomStringConvertible {
        case argument(String)
        case control(String)
        case operation(String)
        case process(String, Int32)

        var description: String {
            switch self {
            case .argument(let message), .control(let message), .operation(let message):
                message
            case .process(let command, let status):
                "\(command) exited with status \(status)"
            }
        }
    }
}
