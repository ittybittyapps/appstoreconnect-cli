// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser

struct ListPreReleaseVersionsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Get a list of prerelease versions for all apps.")

    @OptionGroup()
    var common: CommonOptions

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "The app AppStore ID. eg. 432156789 or app bundle identifier. eg. com.example.App",
            discussion: "Please input either app id or bundle Id",
            valueName: "app-id / bundle-id"
        ),
        transform: Identifier.init
    )
    var filterIdentifiers: [Identifier]

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

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by platform \(Platform.allCases)",
            valueName: "platform"
        )
    )
    var filterPlatforms: [String]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter by version number. eg. 1.0.1",
            valueName: "version"
        )
    )
    var filterVersions: [String]

    @Option(
        parsing: .unconditional,
        help: ArgumentHelp(
            "Sort the results using the provided key \(ListPrereleaseVersions.Sort.allCases).",
            discussion: "The `-` prefix indicates descending order."
        )
    )
    var sort: ListPrereleaseVersions.Sort?
    
    func run() throws {
        let service = try makeService()

        let prereleaseVersions = try service.listPreReleaseVersions(filterIdentifiers: filterIdentifiers, filterVersions: filterVersions, filterPlatforms: filterPlatforms, sort: sort)

        prereleaseVersions.render(format: common.outputFormat)
    }
}

