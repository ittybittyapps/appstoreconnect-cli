//
//  BuildDetails.swift
//  AppStoreConnect-Swift-SDK
//
//  Created by Nafisa Rahman on 27/4/20.
//

import AppStoreConnect_Swift_SDK
import Foundation
import SwiftyTextTable

struct BuildDetailsInfo: ResultRenderable {
  let build: Build?
  let app: AppStoreConnect_Swift_SDK.App?
  let prereleaseVersion: AppStoreConnect_Swift_SDK.PrereleaseVersion?
  let buildBetaDetail: AppStoreConnect_Swift_SDK.BuildBetaDetail?
  let betaAppReviewSubmission: AppStoreConnect_Swift_SDK.BetaAppReviewSubmission?
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

    let app = includedApps?.filter { relationships?.app?.data?.id == $0.id }.first
    let prereleaseVersion = includedPrereleaseVersions?.filter { relationships?.preReleaseVersion?.data?.id == $0.id }.first
    let buildBetaDetail = includedBuildBetaDetails?.filter { relationships?.buildBetaDetail?.data?.id == $0.id }.first
    let betaAppReviewSubmission = includedBetaAppReviewSubmissions?.filter { relationships?.betaAppReviewSubmission?.data?.id == $0.id }.first

    self.init(build: build, app: app, prereleaseVersion: prereleaseVersion, buildBetaDetail: buildBetaDetail, betaAppReviewSubmission: betaAppReviewSubmission)
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
            TextTableColumn(header: "Processing State"),
            TextTableColumn(header: "Min OS Version"),
            TextTableColumn(header: "Uploaded Date"),
            TextTableColumn(header: "Expiration Date"),
            TextTableColumn(header: "Expired"),
            TextTableColumn(header: "Uses Non Exempt Encryption"),
            TextTableColumn(header: "Beta Review state"),
            TextTableColumn(header: "External build state"),
            TextTableColumn(header: "Internal build state"),
            TextTableColumn(header: "Auto Notify"),


            //TextTableColumn(header: "Beta Groups"), - TODO ??
        ]
    }

    var appInfo: [CustomStringConvertible] {
        return [
                app?.attributes?.bundleId,
                app?.attributes?.name
               ]
               .map {$0 ?? ""}
      }

    var prereleaseVersionInfo: [CustomStringConvertible] {
        return [
                prereleaseVersion?.attributes?.platform?.rawValue ,
                prereleaseVersion?.attributes?.version
               ]
               .map {$0 ?? ""}
    }

    var buildBetaDetailInfo: [CustomStringConvertible] {
        return [
                buildBetaDetail?.attributes?.externalBuildState?.rawValue,
                buildBetaDetail?.attributes?.internalBuildState?.rawValue ,
                buildBetaDetail?.attributes?.autoNotifyEnabled?.toYesNo(),
               ]
               .map { $0 ?? ""}
    }

    var buildAttributes: [CustomStringConvertible] {
       return [
                build?.attributes?.version ?? "",
                build?.attributes?.processingState ?? "",
                build?.attributes?.minOsVersion ?? "",
                build?.attributes?.uploadedDate?.formattedDate ?? "",
                build?.attributes?.expirationDate?.formattedDate ?? "",
                build?.attributes?.expired?.toYesNo() ?? "",
                build?.attributes?.usesNonExemptEncryption?.toYesNo() ?? ""
              ]
    }

    var betaAppReviewSubmissionInfo: [CustomStringConvertible] {
        return [
                betaAppReviewSubmission?.attributes?.betaReviewState?.rawValue
               ]
               .map { $0 ?? ""}
    }

    var tableRow: [CustomStringConvertible]  {
        return [
                appInfo.map {$0},
                prereleaseVersionInfo.map {$0},
                buildAttributes.map {$0},
                betaAppReviewSubmissionInfo.map {$0},
                buildBetaDetailInfo.map {$0}
               ]
               .flatMap{$0}
    }
}

