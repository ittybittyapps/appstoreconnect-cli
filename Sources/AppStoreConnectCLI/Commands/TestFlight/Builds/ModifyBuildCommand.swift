// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ModifyBuildCommand: CommonParsableCommand {
  static var configuration = CommandConfiguration(
      commandName: "modify",
      abstract: "Expire a build or change the encryption exemption of a build.")

  @OptionGroup()
  var common: CommonOptions

  @Argument(help: "An opaque resource ID that uniquely identifies the build")
  var bundleId: String

  @Argument(help: "The build number of this build")
  var buildNumber: String

  @Argument(help: "The pre-release version number of this build")
  var preReleaseVersion: String

  @Option(help: "The new value for expired")
  var expired: Bool?

  @Option(help: "The new value for usesNonExemptEncyption")
  var usesNonExemptEncyption: Bool?

  func run() throws {
      let service = try makeService()

    let modifyDetailsInfo = try service.modifyBuild(bundleId: bundleId, buildNumber: buildNumber, preReleaseVersion: preReleaseVersion, expired: expired, usesNonExemptEncyption: usesNonExemptEncyption )

     modifyDetailsInfo.render(format: common.outputFormat)
  }
}
