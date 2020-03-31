// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

struct DeleteBundleIdCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a bundle ID that is used for app development."
    )

    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Argument(help: "The bundle ID to delete. Must be unique.")
    var bundleId: String

    func run() throws {
        let api = try HTTPClient(authenticationYmlPath: auth)

        _ = try api
            .findInternalIdentifier(for: bundleId)
            .flatMap {
                api.request(APIEndpoint.delete(bundleWithId: $0)).eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: { _ in }
            )
    }
}
