// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

struct CancelUserInvitationsCommand: ParsableCommand {
    public static var configuration = CommandConfiguration(
        commandName: "cancel-invitation",
        abstract: "Cancel a pending invitation for a user to join your team."
    )

    @OptionGroup()
    var authOptions: AuthOptions

    @Argument(help: "The email address of a pending user invitation.")
    var email: String

    public func run() throws {
        let api = HTTPClient(configuration: APIConfiguration.load(from: authOptions))

        _ = try api
            .invitationIdentifier(matching: email)
            .flatMap { internalId in
                api.request(APIEndpoint.cancel(userInvitationWithId: internalId))
            }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: { _ in }
            )
    }
}
