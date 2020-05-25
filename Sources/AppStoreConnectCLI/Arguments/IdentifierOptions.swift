// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct IdentifierOptions: ParsableArguments {
    @Option(
        parsing: .upToNextOption,
        help: ArgumentHelp(
            "The app AppStore ID. eg. 432156789 or app bundle identifier. eg. com.example.App",
            discussion: "Please input either app id or bundle Id",
            valueName: "app-id / bundle-id"
        ),
        transform: Identifier.init
    )
    var filterIdentifiers: [Identifier]
}
