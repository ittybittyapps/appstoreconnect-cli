// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation

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
    var filterName: [String]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter the results by the specified device platform \(Platform.allCases).",
            valueName: "platform"
        )
    )
    var filterPlatform: [Platform]

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
    var filterUDID: [String]

    func run() throws {
        let service = try makeService()

        var filters = [Devices.Filter]()

        if !filterName.isEmpty {
            filters.append(.name(filterName))
        }

        if !filterPlatform.isEmpty {
            // API Device attributes use the BundleIdPlatform enum,
            // rather than a Platform, so there is no support for
            // tvOs or watchOs.
            // This appears to be an API issue.
            filters.append(.platform(filterPlatform))
        }

        if !filterUDID.isEmpty {
            filters.append(.udid(filterUDID))
        }

        if let filterStatus = filterStatus {
            filters.append(.status([filterStatus]))
        }

        let request = APIEndpoint.listDevices(
            filter: filters,
            sort: [sort].compactMap { $0 },
            limit: limit
        )

        let result = service.request(request)
            .map { $0.data.map(Device.init) }
            .awaitResult()

        result.render(format: common.outputFormat)
    }
}
