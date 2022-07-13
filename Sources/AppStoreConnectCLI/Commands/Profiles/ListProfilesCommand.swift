// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation
import FileSystem

struct ListProfilesCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list provisioning profiles and download their data.")

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "Limit the number of profiles to return (maximum 200).")
    var limit: Int?

    @Option(
        parsing: .unconditional,
        help: ArgumentHelp(
            "Sort the results using the provided key \(Profiles.Sort.allCases).",
            discussion: "The `-` prefix indicates descending order."
        )
    )
    var sort: Profiles.Sort?

    @Option(
        parsing: .upToNextOption,
        help: "The resource id of the profile."
    )
    var filterId: [String] = []

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter the results by the specified profile name.",
            valueName: "name"
        )
    )
    var filterName: [String] = []

    @Option(
        help: ArgumentHelp(
            "Filter the results by the specified prfile state \(ProfileState.allCases).",
            valueName: "state"
        )
    )
    var filterProfileState: ProfileState?

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter the results by the specified profile types \(ProfileType.allCases).",
            valueName: "type"
        )
    )
    var filterProfileType: [ProfileType] = []

    @Option(help:
        ArgumentHelp(
            "If set, the provisioning profiles will be saved as files to this path.",
            discussion: "Profiles will be saved to files with names of the pattern '<UUID>.\(ProfileProcessor.profileExtension)'.",
            valueName: "path"
        )
    )
    var downloadPath: String?

    func run() throws {
        let service = try makeService()

        let profiles = try service.listProfiles(
            ids: filterId,
            filterName: filterName,
            filterProfileState: filterProfileState,
            filterProfileType: filterProfileType,
            sort: sort,
            limit: limit
        )

        if let path = downloadPath {
            let processor = ProfileProcessor(path: .folder(path: path))

            try profiles.forEach {
                let file = try processor.write($0)

                // Only print if the `PrintLevel` is set to verbose.
                if common.outputOptions.printLevel == .verbose {
                    print("📥 Profile '\($0.name!)' downloaded to: \(file.path)")
                }
            }
        }

        profiles.render(options: common.outputOptions)
    }
}
