// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser

struct ListDevicesCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list devices.")

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "Limit the number of devices to return (maximum 200).")
    var limit: Int?

    @Option(
        parsing: .unconditional,
        help: ArgumentHelp(
            "Sort the results using the provided key \(Devices.Sort.allCases).",
            discussion: "The `-` prefix indicates descending order."
        )
    )
    var sort: Devices.Sort?

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter the results by the specified device name.",
            valueName: "name"
        ),
        transform: { $0.lowercased() }
    )
    var filterName: [String] = []

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter the results by the specified device platform \(Platform.allCases).",
            valueName: "platform"
        )
    )
    var filterPlatform: [Platform] = []

    @Option(
        help: ArgumentHelp(
            "Filter the results by the specified device status \(DeviceStatus.allCases).",
            valueName: "status"
        )
    )
    var filterStatus: DeviceStatus?

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter the results by the specified device udid.",
            valueName: "udid"
        ),
        transform: { $0.lowercased() }
    )
    var filterUDID: [String] = []

    func run() throws {
        let service = try makeService()

        let devices = try service.listDevices(
            filterName: filterName,
            filterPlatform: filterPlatform,
            filterUDID: filterUDID,
            filterStatus: filterStatus,
            sort: sort,
            limit: limit
        )

        devices.render(options: common.outputOptions)
    }
}
