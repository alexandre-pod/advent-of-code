//
//  File.swift
//  
//
//  Created by Alexandre Podlewski on 07/12/2022.
//

import Foundation

protocol File: AnyObject, CustomStringConvertible {
    var parent: File? { get set }
    var name: String { get }
    var subfiles: [File] { get }
    var size: Int { get }
    var isDirectory: Bool { get }

    func getFile(named name: String) -> File?
    func addSubFile(_ file: File)
}

extension File {
    var isDirectory: Bool { false }
}
