// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser

struct BuildArguments: ParsableArguments {
    @Argument(help: "The bundle ID of an application. (eg. com.example.app).")
    var bundleId: String

    @Argument(help: "The pre-release version number of this build. (eg. 1.0.0)")
    var preReleaseVersion: String

    @Argument(help: "The build number of this build. (eg. 1)")
    var buildNumber: String
}
