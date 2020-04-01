// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
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

        ListApps.getResourceIdsFrom(bundleIds: [bundleId], by: api) {
            guard let appId = $0.first else {
                fatalError("Can't find a related app with input bundleID")
            }

            let request = APIEndpoint.builds(ofAppWithId: appId)

            _ = api.request(request)
                .map { $0.data }
                .sink(
                    receiveCompletion: Renderers.CompletionRenderer().render,
                    receiveValue: { (builds: [Build]) in
                        // Sort by uploaded date
                        var builds = builds
                        builds.sort {
                            if let date1 = $0.attributes?.uploadedDate,
                                let date2 = $1.attributes?.uploadedDate {
                                return date1 > date2
                            }
                            return false
                        }

                        Renderers.ResultRenderer(format: self.outputFormat).render(builds)
                    }
                )
        }
    }
}
