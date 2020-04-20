// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct InviteBetaTesterCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
    commandName: "invite",
    abstract: "Invite or reinvite an existing beta tester to test a specified app.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The Beta tester's email address")
    var email: String

    @Argument(help: "The bundle ID of an application. (eg. com.example.app)")
    var bundleId: String

    func run() throws {
        let api = try makeClient()

        _ = api
            .appResourceId(matching: bundleId)
            .combineLatest(try api.betaTesterResourceId(matching: email))
            .flatMap {
                api.request(APIEndpoint.send(invitationForAppWithId: $0, toBetaTesterWithId: $1))
            }
            .sink(
                receiveCompletion: Renderers.CompletionRenderer().render,
                receiveValue: { _ in }
            )
    }
}
