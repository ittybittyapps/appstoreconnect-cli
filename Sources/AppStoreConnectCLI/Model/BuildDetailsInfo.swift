// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation
import SwiftyTextTable

struct BuildDetailsInfo: ResultRenderable {
  let app: App?
  let platform: String?
  let version: String?
  let externalBuildState: String?
  let internalBuildState: String?
  let autoNotifyEnabled: String?
  let buildNumber: String?
  let processingState: String?
  let minOsVersion: String?
  let uploadedDate: String?
  let expirationDate: String?
  let expired: String?
  let usesNonExemptEncryption: String?
  let betaReviewState: String?
}

extension BuildDetailsInfo {

  init(_ build: AppStoreConnect_Swift_SDK.Build ,_ includes: [AppStoreConnect_Swift_SDK.BuildRelationship]?) {

    let relationships = build.relationships

    let includedApps = includes?.compactMap { relationship -> AppStoreConnect_Swift_SDK.App? in
      if case let .app(app) = relationship {
        return app
      }
      return nil
    }

    let includedPrereleaseVersions = includes?.compactMap { relationship -> AppStoreConnect_Swift_SDK.PrereleaseVersion? in
      if case let .preReleaseVersion(prereleaseVersion) = relationship {
        return prereleaseVersion
      }
      return nil
    }

    let includedBuildBetaDetails = includes?.compactMap { relationship -> AppStoreConnect_Swift_SDK.BuildBetaDetail? in
      if case let .buildBetaDetail(buildBetaDetail) = relationship {
        return buildBetaDetail
      }
      return nil
    }

    let includedBetaAppReviewSubmissions = includes?.compactMap { relationship -> AppStoreConnect_Swift_SDK.BetaAppReviewSubmission? in
      if case let .betaAppReviewSubmission(betaAppReviewSubmission) = relationship {
        return betaAppReviewSubmission
      }
      return nil
    }

    let appDetails = includedApps?.filter { relationships?.app?.data?.id == $0.id }.first
    let prereleaseVersion = includedPrereleaseVersions?.filter { relationships?.preReleaseVersion?.data?.id == $0.id }.first
    let buildBetaDetail = includedBuildBetaDetails?.filter { relationships?.buildBetaDetail?.data?.id == $0.id }.first
    let betaAppReviewSubmission = includedBetaAppReviewSubmissions?.filter { relationships?.betaAppReviewSubmission?.data?.id == $0.id }.first

    let app = appDetails.map(App.init)

    self.init(
      app: app,
      platform: prereleaseVersion?.attributes?.platform?.rawValue,
      version: prereleaseVersion?.attributes?.version,
      externalBuildState: buildBetaDetail?.attributes?.externalBuildState?.rawValue,
      internalBuildState: buildBetaDetail?.attributes?.internalBuildState?.rawValue,
      autoNotifyEnabled: buildBetaDetail?.attributes?.autoNotifyEnabled?.toYesNo(),
      buildNumber: build.attributes?.version,
      processingState: build.attributes?.processingState,
      minOsVersion: build.attributes?.minOsVersion,
      uploadedDate: build.attributes?.uploadedDate?.formattedDate,
      expirationDate: build.attributes?.expirationDate?.formattedDate,
      expired: build.attributes?.expired?.toYesNo(),
      usesNonExemptEncryption: build.attributes?.usesNonExemptEncryption?.toYesNo(),
      betaReviewState: betaAppReviewSubmission?.attributes?.betaReviewState?.rawValue
    )
  }
}

extension BuildDetailsInfo: TableInfoProvider {
  static func tableColumns() -> [TextTableColumn] {
    return [
      TextTableColumn(header: "Bundle Id"),
      TextTableColumn(header: "App Name"),
      TextTableColumn(header: "Platform"),
      TextTableColumn(header: "Version"),
      TextTableColumn(header: "Build Number"),
      TextTableColumn(header: "Beta Review state"),
      TextTableColumn(header: "Processing State"),
      TextTableColumn(header: "External build state"),
      TextTableColumn(header: "Internal build state"),
      TextTableColumn(header: "Auto Notify"),
      TextTableColumn(header: "Min OS Version"),
      TextTableColumn(header: "Uploaded Date"),
      TextTableColumn(header: "Expiration Date"),
      TextTableColumn(header: "Expired"),
      TextTableColumn(header: "Uses Non Exempt Encryption")
    ]
  }

  var tableRow: [CustomStringConvertible]  {
    return [
      app?.bundleId,
      app?.name,
      platform,
      version,
      buildNumber,
      betaReviewState,
      processingState,
      externalBuildState,
      internalBuildState,
      autoNotifyEnabled,
      minOsVersion,
      uploadedDate,
      expirationDate,
      expired,
      usesNonExemptEncryption
      ]
      .map { $0 ?? ""}
  }
}
