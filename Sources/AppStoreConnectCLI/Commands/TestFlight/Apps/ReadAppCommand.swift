// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ReadAppCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Find and read app info"
    )

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var appLookupArgument: AppLookupArgument
    
    func run() throws {
        let service = try makeService()

        let app = try service.readApp(identifier: appLookupArgument.identifier)

        app.render(format: common.outputFormat)
    }
}
