// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import FileSystem

struct BuildLocalizationInputArguments: ParsableArguments {
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
}

protocol CreateUpdateBuildLocalizationCommand {
    var localization: BuildLocalizationInputArguments { get }
}

extension CreateUpdateBuildLocalizationCommand {

    func validateWhatsNewInput() throws {
        if localization.whatsNew == nil && localization.path == nil {
            throw ValidationError("Please either use --whatsNew or --path option to provide whats new info.")
        }

        if localization.whatsNew != nil && localization.path != nil {
            throw ValidationError("Please provide either a file path or whats new text in terminal.")
        }
    }

    var whatsNew: String {
        if let whatsNew = localization.whatsNew {
            return whatsNew
        } else if let filePath = localization.path {
            return Readers.FileReader<String>(format: .txt).readTXT(from: filePath)
        }

        return ""
    }

}
