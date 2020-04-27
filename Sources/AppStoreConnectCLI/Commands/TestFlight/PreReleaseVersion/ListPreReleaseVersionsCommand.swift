// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct ListPreReleaseVersionsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Get a list of prerelease versions for all apps.")

    @OptionGroup()
    var common: CommonOptions

    @Option()
    var filterApp: [String]

    // --filter-platform <platforms...>
    // --filter-version <versions...>

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

        var filter: [ListPrereleaseVersions.Filter] = []

        if filterBuildProcessingState.isEmpty == false {
            filter.append(.buildsProcessingState(filterBuildProcessingState))
        }

        // FIXME: Underlying SDK API doesn't expose limits correctly.
        let request = APIEndpoint.prereleaseVersions(
            filter: filter,
            include: [.app]
//            limit: [ListPrereleaseVersions.Limit]? = nil,
            sort: sort
        )

        let versions = try service.request(request)
            .map([PreReleaseVersion].init)
            .await()

        versions.render(format: common.outputFormat)
    }
}
