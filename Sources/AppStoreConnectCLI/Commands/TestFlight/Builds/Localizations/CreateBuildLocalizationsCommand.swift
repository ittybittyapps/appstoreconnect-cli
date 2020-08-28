// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import FileSystem

struct CreateBuildLocalizationsCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Create localized What’s New text for a build."
    )

    @OptionGroup()
    var common: CommonOptions

    @OptionGroup()
    var build: BuildArguments

    @Argument(help: "The locale information of the build localization resource. eg. (en-AU)")
    var locale: String

    @Option(
        parsing: SingleValueParsingStrategy.scanningForValue,
        help: """
            A field that describes changes and additions to a build and indicates features you would like your users to test.
            Please put the text inside an ''.
            eg. ('Hello There')
        """
    )
    var whatsNew: String?

    @Option(help: "File path to a txt file that contains whats new text. (eg. whatsNew.txt)")
    var path: String?

    func validate() throws {
        if whatsNew == nil && path == nil {
            throw ValidationError("Please either use --whatsNew or --path option to provide whats new info.")
        }

        if whatsNew != nil && path != nil {
            throw ValidationError("Please provide either a file path or whats new text in terminal.")
        }
    }

    func run() throws {
        let service = try makeService()

        var whatsNewText: String = ""

        if let whatsNew = whatsNew {
            whatsNewText = whatsNew
        } else if let filePath = path {
            whatsNewText = Readers.FileReader<String>(format: .txt).readTXT(from: filePath)
        }

        let buildLocalization = try service.createBuildLocalization(
            bundleId: build.bundleId,
            buildNumber: build.buildNumber,
            preReleaseVersion: build.preReleaseVersion,
            locale: locale,
            whatsNew: whatsNewText
        )

        // Render long text by SwiftyTable is not supported yet
        [buildLocalization].render(format: common.outputFormat == .table ? .json : common.outputFormat)
    }
}
