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
    var string: String

    @Argument(help: "The type of profile to create \(ProfileType.allCases)")
    var profileType: ProfileType

    @Argument(help: "The reverse-DNS bundle ID identifier to associate with this profile (must already exist).")
    var bundleId: String

    @Argument(help: "Certificates") // TODO
    var certificates: [String]

    @Option(help: "Devices") // TODO
    var devices: [String]

    func run() throws {
        fatalError("Not implementedf")
    }
}
