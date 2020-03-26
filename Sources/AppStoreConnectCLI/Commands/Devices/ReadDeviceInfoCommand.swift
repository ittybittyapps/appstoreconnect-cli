// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation
import SwiftyTextTable
import Yams

struct ReadDeviceInfoCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Get information for a specific device registered to your team"
    )

    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Argument(help: "The ID of the device to find")
    var deviceId: String

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    func run() throws {
        let api = try HTTPClient(authenticationYmlPath: auth)

        let request = APIEndpoint.readDeviceInformation(id: deviceId)

        _ = api.request(request)
            .map { Device.fromAPIDevice($0.data) }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: outputFormat).render
            )
    }

}
