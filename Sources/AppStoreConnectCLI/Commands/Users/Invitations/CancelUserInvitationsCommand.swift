// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct CancelUserInvitationsCommand: CommonParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "cancel-invitation",
        abstract: "Cancel a pending invitation for a user to join your team."
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The email address of a pending user invitation.")
    var email: String

    public func run() throws {
        let service = try makeService()

        let cancelInvitation = { service.request(APIEndpoint.cancel(userInvitationWithId: $0)) }

        try service
            .invitationIdentifier(matching: email)
            .flatMap(cancelInvitation)
            .await()
    }
}
