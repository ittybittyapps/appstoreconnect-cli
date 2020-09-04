// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import FileSystem
import Foundation

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
        if localization.whatsNew != nil && localization.path != nil {
            throw ValidationError("Please provide either a file path or whats new text in terminal.")
        }
    }

    func readWhatsNew() throws -> String {
        let whatsNew: String

        if let whatsNewFromOption = localization.whatsNew {
            whatsNew = whatsNewFromOption
        } else if let filePath = localization.path {
            whatsNew = try String(contentsOfFile: filePath)
        } else {
            var whatsNewStdin: [String] = []

            while let line = readLine() {
                whatsNewStdin.append(line)
            }

            whatsNew = whatsNewStdin.joined(separator: "\n")
        }

        return whatsNew
    }

}
