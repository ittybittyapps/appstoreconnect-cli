// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation
import SwiftyTextTable
import Yams

struct ReadDeviceInfoCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Get information for a specific device registered to your team"
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The ID of the device to find")
    var deviceId: String

    func run() throws {
        let api = try makeClient()

        let request = APIEndpoint.readDeviceInformation(id: deviceId)

        _ = api.request(request)
            .map { Device.fromAPIDevice($0.data) }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }

}
