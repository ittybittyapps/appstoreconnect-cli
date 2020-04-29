// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation
import Files

struct ListProfilesCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "list",
        abstract: "Find and list provisioning profiles and download their data.")

    @OptionGroup()
    var common: CommonOptions

    @Option(help: "Limit the number of profiles to return (maximum 200).")
    var limit: Int?

    @Option(
        parsing: .unconditional,
        help: ArgumentHelp(
            "Sort the results using the provided key \(Profiles.Sort.allCases).",
            discussion: "The `-` prefix indicates descending order."
        )
    )
    var sort: Profiles.Sort?

    // TODO?: filter[id]

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter the results by the specified profile name.",
            valueName: "name"
        )
    )
    var filterName: [String]

    @Option(
        help: ArgumentHelp(
            "Filter the results by the specified prfile state \(ProfileState.allCases).",
            valueName: "state"
        )
    )
    var filterProfileState: ProfileState?

    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "Filter the results by the specified profile types \(ProfileType.allCases).",
            valueName: "type"
        )
    )
    var filterProfileType: [ProfileType]

    @Option(help:
        ArgumentHelp(
            "If set, the provisioning profiles will be saved as files to this path.",
            discussion: "Profiles will be saved to files with names of the pattern '<UUID>.\(profileExtension)'.",
            valueName: "path"
        )
    )
    var downloadPath: String?

    static let profileExtension = "mobileprovision"

    func run() throws {
        let api = try makeService()

        var filters = [Profiles.Filter]()

        if !filterName.isEmpty {
            filters.append(.name(filterName))
        }

        if let filterProfileState = filterProfileState {
            filters.append(.profileState([filterProfileState]))
        }

        if !filterProfileType.isEmpty {
            filters.append(.profileType(filterProfileType))
        }

        var limits = [Profiles.Limit]()
        if let limit = limit {
            limits.append(.profiles(limit))
        }

        let request = APIEndpoint.listProfiles(
            filter: filters,
            include: [.bundleId, .certificates, .devices],
            sort: [sort].compactMap { $0 },
            limit: limits
        )

        let profiles = try api.request(request)
            .map { $0.data.map(Profile.init) }
            .saveProfile(downloadPath: self.downloadPath) // FIXME: This feels like a hack.
            .await()

        profiles.render(format: common.outputFormat)
    }
}

private extension Publisher where Output == [Profile], Failure == Error {
    func saveProfile(downloadPath: String?) -> AnyPublisher<Output, Failure> {
        tryMap { profiles -> Output in
            if let path = downloadPath {

                let folder = try Folder(path: path)
                for profile in profiles {
                    let file = try folder.createFile(
                        named: "\(profile.uuid!).\(ListProfilesCommand.profileExtension)",
                        contents: Data(base64Encoded: profile.profileContent!)!
                    )
                    Swift.print("📥 Profile '\(profile.name!)' downloaded to: \(file.path)")
                }
            }

            return profiles
        }.eraseToAnyPublisher()
    }
}
