//
//  File 2.swift
//  
//
//  Created by Alexandre Podlewski on 07/12/2022.
//

import Foundation

class RawFile: File {
    weak var parent: File?
    let name: String
    let size: Int

    init(name: String, size: Int) {
        self.name = name
        self.size = size
    }

    // MARK: - File

    var subfiles: [File] { [] }

    func getFile(named name: String) -> File? {
        return nil
    }

    func addSubFile(_ file: File) {
        assertionFailure("Unsupported operation")
    }
}

extension RawFile: CustomStringConvertible {
    var description: String {
        return "\(size) - \(name)"
    }
}
