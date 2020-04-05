// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

struct ModifyBundleIdCommand: CommonParsableCommand {

    public static var configuration = CommandConfiguration(
        commandName: "modify",
        abstract: "Update a specific bundle ID's name."
    )

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "The reverse-DNS bundle ID identifier. (eg. com.example.app)")
    var identifier: String

    @Option(help: "The new name for the bundle identifier.")
    var name: String

    func run() throws {
        let api = makeClient()

        _ = try api
            .internalId(matching: identifier)
            .flatMap { internalId in
                api.request(APIEndpoint.modifyBundleId(id: internalId, name: self.name)).eraseToAnyPublisher()
            }
            .map(BundleId.init)
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }
}
