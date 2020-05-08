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

    @Argument(
        help: ArgumentHelp(
            "The app AppStore ID. eg. 432156789 or app bundle identifier. eg. com.example.App",
            discussion: "Please input either app id or bundle Id",
            valueName: "app-id / bundle-id"
        ),
        transform: Identifier.init
    ) var identifier: Identifier

    enum Identifier {
        case appId(String)
        case bundleId(String)

        init(_ argument: String) {
            switch Int(argument) == nil {
            case true:
                self = .bundleId(argument)
            case false:
                self = .appId(argument)
            }
        }
    }

    func run() throws {
        let service = try makeService()

        var app: App

        switch identifier {
        case .appId(let appId):
            app = try service.readApp(appId: appId)
        case .bundleId(let bundleId):
            app = try service.readApp(bundleId: bundleId)
        }

        app.render(format: common.outputFormat)
    }
}
