// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import FileSystem

struct ReadProfileCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Find and read a provisioning profile and download it data.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The resource id of the provisioning profile to read.")
    var id: String

    @Option(
        help: ArgumentHelp(
            "If set, the provisioning profiles will be saved as files to this path.",
            discussion: "Profiles will be saved to files with names of the pattern '<UUID>.\(ProfileProcessor.profileExtension)'.",
            valueName: "path"
        )
    )
    var downloadPath: String?

    func run() throws {
        let service = try makeService()

        let profile = try service.readProfile(id: id)

        if let path = downloadPath {
            let processor = ProfileProcessor(path: .folder(path: path))
            let file = try processor.write(profile)

            print("📥 Profile '\(profile.name!)' downloaded to: \(file.path)")
        }

        [profile].render(format: common.outputFormat)
    }
}
