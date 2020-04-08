// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct DevicesCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "devices",
        abstract: "Register devices for development and testing.",
        subcommands: [
            ListDevicesCommand.self,
            ReadDeviceInfoCommand.self,
            /* TODO
            RegisterDeviceCommand.self, // Register a new device for app development.
            UpdateDeviceCommand.self, // Update the name or status of a specific device.
            SyncDevicesCommand.self, // Synchronise devices with configuration file
            */
        ],
        defaultSubcommand: ListDevicesCommand.self
    )
}
