// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ExpireBuildCommand: CommonParsableCommand {
  static var configuration = CommandConfiguration(
      commandName: "expire",
      abstract: "Expire a build.")

  @OptionGroup()
  var common: CommonOptions

  @Argument(help: "An opaque resource ID that uniquely identifies the build")
  var bundleId: String

  @Argument(help: "The pre-release version number of this build")
  var preReleaseVersion: String

  @Argument(help: "The build number of this build")
  var buildNumber: String

  @Argument(help: "The new value for expired")
  var expired: Bool

  func run() throws {
      let service = try makeService()

      _ = try service.expireBuild(bundleId: bundleId, buildNumber: buildNumber, preReleaseVersion: preReleaseVersion, expired: expired)
  }
}
