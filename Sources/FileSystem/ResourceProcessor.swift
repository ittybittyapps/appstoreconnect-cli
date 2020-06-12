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

extension PathProvider {
    func getFolder() throws -> Folder {
        var folder: Folder
        switch path {
        case .file(let path):
            let standardizedPath = path as NSString
            folder = try Folder(path: "").createSubfolderIfNeeded(at: standardizedPath.deletingLastPathComponent)
        case .folder(let folderPath):
            folder = try Folder(path: "").createSubfolderIfNeeded(at: folderPath)
        }

        return folder
    }
}

extension ResourceWriter {

    func writeFile(_ resource: FileProvider) throws -> File {
        var file: File
        var fileName: String

        switch path {
        case .file(let path):
            let standardizedPath = path as NSString
            fileName = standardizedPath.lastPathComponent
        case .folder:
            fileName = resource.fileName
        }

        let folder: Folder = try getFolder()

        switch try resource.fileContent() {
        case .data(let data):
            file = try folder.createFileIfNeeded(withName: fileName, contents: data)
        case .string(let string):
            file = try folder.createFileIfNeeded(at: fileName)
            try file.write(string)
        }

        return file
    }

    func deleteFile() {
        do {
            switch path {
            case .file(let filePath):
                let standardizedPath = filePath as NSString
                try Folder(path: standardizedPath.deletingLastPathComponent)
                    .files.forEach {
                        if $0.name == standardizedPath.lastPathComponent {
                            try $0.delete()
                        }
                    }
            case .folder(let folderPath):
                try Folder(path: folderPath)
                    .files.forEach { try $0.delete() }
            }
        } catch {
            // Skip delete failed error, if folder is missing.
        }
    }
}
