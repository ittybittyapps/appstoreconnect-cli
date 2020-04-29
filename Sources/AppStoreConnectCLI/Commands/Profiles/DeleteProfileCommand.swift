// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct DeleteProfileCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "delete",
        abstract: "Delete a provisioning profile that is used for app development or distribution.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The UUID of the provisioning profile to delete.")
    var uuid: String

    func run() throws {
        let api = try makeService()

        try api
            .profileResourceId(matching: uuid)
            .flatMap { api.request(APIEndpoint.delete(profileWithId: $0)) }
            .await()
    }
}
