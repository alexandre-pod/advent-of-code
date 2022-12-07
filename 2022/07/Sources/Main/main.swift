import Foundation

enum Input {
    case command(CommandInput)
    case output(CommandOutput)
}

enum CommandInput {
    case list
    case changeDirectory(DirectoryTarget)
}

struct DirectoryTarget: RawRepresentable {
    let rawValue: String
    
    static let parentDirectory = DirectoryTarget(rawValue: "..")
    static let rootDirectory = DirectoryTarget(rawValue: "/")
}

enum CommandOutput {
    case directory(name: String)
    case file(name: String, size: Int)
}

func main() {
    var lines: [Input] = []

    while let line = readLine() {
        if line.starts(with: "$") {
            lines.append(.command(parseCommandInput(from: line)))
        } else {
            lines.append(.output(parseCommandOutput(from: line)))
        }
    }

    print(part1(lines: lines))
    print(part2(lines: lines))
}

private func parseCommandInput(from line: String) -> CommandInput {
    let command = line.dropFirst(2)
    if command == "ls" {
        return .list           
    } else if command.starts(with: "cd") {
        return .changeDirectory(
            DirectoryTarget(rawValue: String(command.split(separator: " ").last!))
        )
    } else {
        fatalError("Syntax error on line: \(line)")
    }
}

private func parseCommandOutput(from line: String) -> CommandOutput {
    if line.starts(with: "dir") {
        let directoryName = String(line.split(separator: " ").last!)
        return .directory(name: directoryName)
    } else {
        let components = line.split(separator: " ")
        let size = Int(components[0])!
        let name = String(components[1])
        return .file(name: name, size: size)
    }
}

// MARK: - Part 1

func part1(lines: [Input]) -> Int {
    let root = constructFileTree(from: lines)
//    print(root)
//    print(allDirectories(from: root).map(\.name))

    return allDirectories(from: root)
        .map(\.size)
        .filter { $0 <= 100000 }
        .reduce(0, +)
}

func constructFileTree(from lines: [Input]) -> File {
    var root: File = Directory(name: "/", subfiles: [])
    var currentDirectory = root
    for line in lines {
        switch line {
        case .command(let commandInput):
            switch commandInput {
            case .list:
                break
            case .changeDirectory(let directoryTarget):
                currentDirectory = currentDirectory.getFile(named: directoryTarget.rawValue)!
            }
        case .output(let commandOutput):
            switch commandOutput {
            case .directory(let name):
                guard currentDirectory.getFile(named: name) == nil else { break }
                currentDirectory.addSubFile(Directory(name: name, subfiles: []))
            case .file(let name, let size):
                guard currentDirectory.getFile(named: name) == nil else { break }
                currentDirectory.addSubFile(RawFile(name: name, size: size))
            }
        }
    }
    return root
}

func allDirectories(from file: File) -> [File] {
    guard file.isDirectory else { return [] }
    return [file] + file.subfiles.flatMap { allDirectories(from: $0) }
}

// MARK: - Part 2

func part2(lines: [Input]) -> Int {
    let totalSize = 70000000
    let requiredFreeSpace = 30000000

    let root = constructFileTree(from: lines)

    let usedSpace = root.size
    let spaceToFreeRequired = max(0, requiredFreeSpace - (totalSize - usedSpace))

    return allDirectories(from: root)
        .map(\.size)
        .filter { $0 >= spaceToFreeRequired }
        .min()!
}

main()
