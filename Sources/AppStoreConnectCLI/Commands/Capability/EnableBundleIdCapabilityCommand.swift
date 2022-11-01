// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import ArgumentParser
import struct Model.BundleIdCapability

struct EnableBundleIdCapabilityCommand: CommonParsableCommand {

    public static var configuration = CommandConfiguration(
        commandName: "enable",
        abstract: "Enable a capability for a bundle ID."
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The reverse-DNS bundle ID identifier to delete. Must be unique. (eg. com.example.app)")
    var bundleId: String

    @Argument(help: ArgumentHelp("Bundle Id capability type.", discussion: "List of \(CapabilityType.allValueStrings.formatted(.list(type: .or)))"))
    var capabilityType: [CapabilityType]

    // TODO: CapabilitySetting

    func run() async throws {
        let service = try BagbutikService(authOptions: common.authOptions)
        let bundleId = try await ReadBundleIdOperation(
            service: service,
            options: .init(bundleId: bundleId)
        )
            .execute()
        
        let result = try await withThrowingTaskGroup(of: Model.BundleIdCapability.self) { group in
            for type in capabilityType {
                group.addTask {
                    try await Model.BundleIdCapability(
                        EnableBundleIdCapabilityOperation(
                            service: service,
                            options: .init(bundleIdResourceId: bundleId.id, capabilityType: type)
                        )
                        .execute()
                    )
                }
            }
            
            var values = [Model.BundleIdCapability]()
            for try await value in group {
                values.append(value)
            }
            
            return values
        }
        
        // TODO: should list capabilities on bundleId
        
        result.render(options: common.outputOptions)
    }
}
