// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ModifyDeviceCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "modify",
        abstract: "Update the name or status of a specific device."
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The UDID of the device to find.")
    var udid: String

    @Argument(help: "The new name for the device.")
    var name: String

    @Argument(help: "The new status for the device \(DeviceStatus.allCases).")
    var status: DeviceStatus

    func run() throws {
        let api = try makeClient()

        _ = try api
            .deviceUDIDResourceId(matching: udid)
            .flatMap { identifier in
                api.request(APIEndpoint.modifyRegisteredDevice(id: identifier, name: self.name, status: self.status))
            }
            .map(Device.init)
            .renderResult(format: common.outputFormat)
    }

}
