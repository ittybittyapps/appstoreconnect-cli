// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Files

/// Resource processor root path
public enum ResourcePath {
    /// folder: The certain *path* of the folder
    /// - path: resource processor root path will be the path of a folder, file be written inside this folder. (eg. documents/foldername/)
    case folder(path: String)
    /// file: path The certain *path* of the file
    /// - path: resource processor root path will be the path of a file, file will be written to the certain path with certain name. (eg. documents/foldername/filename.txt)
    case file(path: String)
}

protocol ResourceProcessor: ResourceReader, ResourceWriter { }

protocol ResourceReader: PathProvider {
    associatedtype T: Codable, FileProvider

    func read() throws -> [T]
}

protocol ResourceWriter: PathProvider {
    associatedtype T: Codable, FileProvider

    func write(_: [T]) throws -> [File]

    func write(_: T) throws -> File
}

protocol PathProvider {
    var path: ResourcePath { get }
}

extension ResourceWriter {

    func writeFile(_ resource: FileProvider) throws -> File {
        var file: File

        switch path {
        case .file(let path):
            let standardizedPath = path as NSString
            file = try Folder(path: standardizedPath.deletingLastPathComponent)
                .createFile(
                    named: standardizedPath.lastPathComponent,
                    contents: resource.fileContent()
                )
        case .folder(let folderPath):
            file = try Folder(path: folderPath)
                .createFile(
                    named: resource.fileName,
                    contents: resource.fileContent()
                )
        }

        return file
    }
}

protocol FileProvider: FileNameProvider, FileContentProvider { }

protocol FileNameProvider {
    var fileName: String { get }
}

protocol FileContentProvider {
    func fileContent() throws -> Data
}
