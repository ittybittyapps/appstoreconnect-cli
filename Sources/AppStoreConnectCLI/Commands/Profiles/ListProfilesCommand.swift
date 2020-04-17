// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

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

    // TODO?: filter[id]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter the results by the specified profile name.",
            valueName: "name"
        )
    )
    var filterName: [String]

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
    var filterProfileType: [ProfileType]

    func run() throws {
        let api = try makeClient()

        var filters = [Profiles.Filter]()

        if !filterName.isEmpty {
            filters.append(.name(filterName))
        }

        if let filterProfileState = filterProfileState {
            filters.append(.profileState([filterProfileState]))
        }

        if !filterProfileType.isEmpty {
            filters.append(.profileType(filterProfileType))
        }

        var limits = [Profiles.Limit]()
        if let limit = limit {
            limits.append(.profiles(limit))
        }

        let request = APIEndpoint.listProfiles(
            filter: filters,
            include: [.bundleId, .certificates, .devices],
            sort: [sort].compactMap { $0 },
            limit: limits
        )

        _ = api.request(request)            
            .map { $0.data.map(Profile.init) }
            .renderResult(format: common.outputFormat)
    }
}
