// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation
import SwiftyTextTable
import Yams

struct ListDevicesCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list devices")

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "Limit the number of devices to return (maximum 200).")
    var limit: Int?

    @Option(
        parsing: SingleValueParsingStrategy.unconditional,
        help: "Sort the results using the provided key (\(Devices.Sort.allCases.map { $0.rawValue }.joined(separator: ", "))).\nThe `-` prefix indicates descending order."
    )
    var sort: Devices.Sort?

    @Option(
        parsing: .upToNextOption,
        help: "Filter the results by the specified device name.",
        transform: { $0.lowercased() }
    )
    var filterName: [String]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(stringLiteral: "Filter the results by the specified device platform (\(BundleIdPlatform.allCases.map { $0.rawValue.lowercased() }.joined(separator: ", "))).")
    )
    var filterPlatform: [BundleIdPlatform]

    @Option(help: "Filter the results by the specified device status (\(DeviceStatus.allCases.map { $0.rawValue.lowercased() }.joined(separator: ", "))).")
    var filterStatus: DeviceStatus?

    @Option(
        parsing: .upToNextOption,
        help: "Filter the results by the specified device udid.",
        transform: { $0.lowercased() }
    )
    var filterUDID: [String]

    func run() throws {
        let api = try makeClient()

        var filters = [Devices.Filter]()

        if !filterName.isEmpty {
            filters.append(Devices.Filter.name(filterName))
        }

        if !filterPlatform.isEmpty {
            // API Device attributes use the BundleIdPlatform enum,
            // rather than a Platform, so there is no support for
            // tvOs or watchOs.
            // This appears to be an API issue.
            filters.append(Devices.Filter.platform(filterPlatform.map { $0 == .iOS ? Platform.ios : Platform.macOs}))
        }

        if !filterUDID.isEmpty {
            filters.append(Devices.Filter.udid(filterUDID))
        }

        if let filterStatus = filterStatus {
            filters.append(Devices.Filter.status([filterStatus]))
        }

        let request = APIEndpoint.listDevices(fields: nil,
                                              filter: filters,
                                              sort: [sort].compactMap { $0 },
                                              limit: limit,
                                              next: nil)

        let _ = api.request(request)
            .map { $0.data.map(Device.fromAPIDevice) }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: Renderers.ResultRenderer(format: common.outputFormat).render
            )
    }
}
