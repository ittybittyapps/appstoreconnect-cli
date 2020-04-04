// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ListBuildsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list builds for one app in App Store Connect.")

    @OptionGroup()
    var authOptions: AuthOptions

    @Argument(help: "A bundle identifier that uniquely identifies an application.")
    var bundleId: String

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    func run() throws {
        let api = HTTPClient(configuration: APIConfiguration.load(from: authOptions))

        _ = api
            .getAppResourceIdsFrom(bundleIds: [bundleId])
            .flatMap { (resoureceIds: [String]) -> AnyPublisher<BuildsResponse, Error> in
                guard let appId = resoureceIds.first else {
                    fatalError("Can't find a related app with input bundleID")
                }

                let endpoint = APIEndpoint.builds(
                    filter: [ListBuilds.Filter.app([appId])],
                    sort: [ListBuilds.Sort.uploadedDateAscending]
                )

                return api.request(endpoint).eraseToAnyPublisher()
            }
            .map { $0.data }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: self.outputFormat).render
            )
    }
}