// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct CreateProfileCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create a new provisioning profile.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The name of the provisioning profile to create.")
    var name: String

    @Argument(help: "The type of profile to create \(ProfileType.allCases).")
    var profileType: ProfileType

    @Argument(help: "The reverse-DNS bundle ID identifier to associate with this profile (must already exist).")
    var bundleId: String

    @Option(
        parsing: .upToNextOption,
        help: "The resource ids of Certificates."
    )
    var certificates: [String]

    @Option(help: "The resource ids of Devices.")
    var devices: [String]

    func run() throws {
        let service = try makeService()

        let profile = try service.createProfile(
            name: name,
            bundleId: bundleId,
            profileType: profileType,
            certificateIds: certificates,
            deviceIds: devices
        )

        [profile].render(format: common.outputFormat)
    }

}
