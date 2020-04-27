// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import Files
import Foundation
import XCTest

final class FilesTests: XCTestCase {
    func testGetFolderAndFileName_withSlash_returnCorrectName() {
        let (folderName, fileName) = File
            .getFolderAndFileName(
                from: "/user/documents/foo.cer"
            )

        XCTAssertEqual(folderName, "/user/documents")
        XCTAssertEqual(fileName, "foo.cer")
    }
    func testGetFolderAndFileName_withoutSlash_returnCorrectName() {
        let (folderName, fileName) = File
            .getFolderAndFileName(
                from: "bar.cer"
            )

        XCTAssertEqual(folderName, ".")
        XCTAssertEqual(fileName, "bar.cer")
    }
}
