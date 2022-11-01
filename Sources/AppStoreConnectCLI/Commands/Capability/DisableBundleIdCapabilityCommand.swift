// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import ArgumentParser

struct DisableBundleIdCapabilityCommand: CommonParsableCommand {

    public static var configuration = CommandConfiguration(
        commandName: "disable",
        abstract: "Disable a capability for a bundle ID."
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The reverse-DNS bundle ID identifier to delete. Must be unique. (eg. com.example.app)")
    var bundleId: String

    @Argument(
        help: ArgumentHelp("Bundle Id capability type.", discussion: "List of \(CapabilityType.allValueStrings.formatted(.list(type: .or)))"),
        completion: .list(CapabilityType.allValueStrings)
    )
    var capabilityType: [CapabilityType]

    func run() async throws {

        let service = try BagbutikService(authOptions: common.authOptions)
        let bundleIdResourceId = try await ReadBundleIdOperation(
                service: service,
                options: .init(bundleId: bundleId)
            )
            .execute()
            .id

        let capabilityIdentifiers = try await ListCapabilitiesOperation(
                service: service,
                options: .init(bundleIdResourceId: bundleIdResourceId)
            )
            .execute()
            .filter { capabilityType.contains($0.attributes!.capabilityType!) }
            .map { $0.id }

        await withThrowingTaskGroup(of: Void.self) { group in
            for id in capabilityIdentifiers {
                group.addTask {
                    try await DisableBundleIdCapabilityOperation(service: service, options: .init(capabilityId: id)).execute()
                }
            }
        }
        
        // TODO: should list capabilities on bundleId
    }
}
