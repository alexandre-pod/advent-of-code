//
//  File 2.swift
//  
//
//  Created by Alexandre Podlewski on 07/12/2022.
//

import Foundation

class Directory: File {
    weak var parent: File?
    let name: String
    var subfiles: [File]

    init(name: String, subfiles: [File]) {
        self.name = name
        self.subfiles = subfiles
    }

    // MARK: - File

    let isDirectory = true

    var size: Int {
        subfiles.reduce(0) { $0 + $1.size }
    }

    func getFile(named name: String) -> File? {
        switch name {
        case "..":
            return parent
        case "/":
            var root: any File = self
            while let parent = self.parent {
                root = parent
            }
            return root
        default:
            return subfiles.first { $0.name == name }
        }
    }

    func addSubFile(_ file: File) {
        assert(subfiles.allSatisfy { $0.name != file.name }, "File already exists")
        subfiles.append(file)
        file.parent = self
    }
}

extension Directory: CustomStringConvertible {
    var description: String {
        let directoryName = "- \(name)"
        let filesName = subfiles.map { $0.description.linePrefixed(by: "  ") }
        return ([directoryName] + filesName).joined(separator: "\n")
    }
}

extension String {
    func linePrefixed(by prefix: String) -> String {
        return split(separator: "\n").map { prefix + $0 }.joined(separator: "\n")
    }
}
