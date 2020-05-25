// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation
import struct Model.Device

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
        let service = try makeService()

        let device = try service
            .deviceUDIDResourceId(matching: udid)
            .flatMap {
                service.request(APIEndpoint.modifyRegisteredDevice(id: $0, name: self.name, status: self.status))
            }
            .map(Device.init)
            .await()

        device.render(format: common.outputFormat)
    }

}
