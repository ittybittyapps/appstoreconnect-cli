// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation
import Yams

struct ListAppsCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list apps")

    @Option(default: "config/auth.yml", help: "The APIConfiguration.") var auth: String

    func run() throws {
        let authYml = try String(contentsOfFile: auth)
        let configuration: APIConfiguration = try YAMLDecoder().decode(from: authYml)
        let api = APIProvider(configuration: configuration)

        let group = DispatchGroup()
        group.enter()

        api.request(.apps()) { result in
            switch result {
            case .success(let appsResponse):
                print("Did fetch \(appsResponse.data.count) apps")
                dump(appsResponse)
            case .failure(let error):
                print("Something went wrong fetching the apps: \(error)")
            }

            group.leave()
        }

        group.wait()
    }
}
