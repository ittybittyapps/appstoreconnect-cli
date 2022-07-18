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

    public func run() async throws {
        let service = try makeService()
       
        try await service.cancel(userInvitationWithId: service.invitationIdentifier(matching: email))
    }
}
