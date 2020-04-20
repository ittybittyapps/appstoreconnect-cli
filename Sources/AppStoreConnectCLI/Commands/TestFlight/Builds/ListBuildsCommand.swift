// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBuildsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list builds for one app in App Store Connect.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "A bundle identifier that uniquely identifies an application.")
    var bundleId: String

    func run() throws {
        let api = try makeClient()

        _ = api
            .appResourceId(matching: bundleId)
            .flatMap {
                api.request(APIEndpoint.builds(
                    filter: [ListBuilds.Filter.app([$0])],
                    sort: [ListBuilds.Sort.uploadedDateAscending]
                ))
            }
            .map { $0.data }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }
}
