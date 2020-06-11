// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

protocol FileProvider: FileNameProvider, FileContentProvider { }

protocol FileNameProvider {
    var fileName: String { get }
}

enum FileContent {
    case data(Data)
    case string(String)
}

protocol FileContentProvider {
    func fileContent() throws -> FileContent
}
