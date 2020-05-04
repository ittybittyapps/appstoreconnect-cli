// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct DeleteBetaTesterCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete beta testers")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "Beta testers' emails")
    var emails: [String]

    func run() throws {
        let service = try makeService()

        _ = try service.deleteBetaTesters(emails: emails)
    }
}
