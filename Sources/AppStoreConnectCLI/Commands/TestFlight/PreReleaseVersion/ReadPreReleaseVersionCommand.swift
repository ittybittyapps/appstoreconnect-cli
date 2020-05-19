// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ReadPreReleaseVersionCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Get information about a specific prerelease version.")

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

        switch (identifier) {
        case .appId(let filterAppId):
            let prereleaseVersion = try service.readPreReleaseVersion(filterAppId: filterAppId)
            prereleaseVersion.render(format: common.outputFormat)
        case .bundleId(let filterBundleId):
            let prereleaseVersion = try service.readPreReleaseVersion(filterBundleId: filterBundleId)
            prereleaseVersion.render(format: common.outputFormat)
        }
    }
}
