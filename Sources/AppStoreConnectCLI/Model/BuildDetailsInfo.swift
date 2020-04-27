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
  let attributes: Build.Attributes?
  let app: AppStoreConnect_Swift_SDK.App?
}

extension BuildDetailsInfo {
  init(_ build: AppStoreConnect_Swift_SDK.Build ,_ includes: [AppStoreConnect_Swift_SDK.BuildRelationship]?) {

    let attributes = build.attributes
    let relationships = build.relationships

    let includedApps = includes?.compactMap { relationship -> AppStoreConnect_Swift_SDK.App? in
        if case let .app(app) = relationship {
            return app
        }
        return nil
    }

    let app = includedApps?.filter { relationships?.app?.data?.id == $0.id }.first
    self.init(attributes: attributes, app: app)
  }
}

extension BuildDetailsInfo: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
       return [
            TextTableColumn(header: "Bundle Id"),
            TextTableColumn(header: "App Name"),
            //TextTableColumn(header: "Platform"),  - TODO from PrereleaseVersion
            //TextTableColumn(header: "Version"), - TODO from PrereleaseVersion
            TextTableColumn(header: "Build Number"),
            //TextTableColumn(header: "Beta Review state"), - TODO from betaAppReviewSubmission
            TextTableColumn(header: "Processing State"),
            //TextTableColumn(header: "External build state"), - TODO from BuildBetaDetail
            //TextTableColumn(header: "Internal build state"), - TODO from BuildBetaDetail
            //TextTableColumn(header: "Auto Notify"), - TODO from BuildBetaDetail
            TextTableColumn(header: "Min OS Version"),
            TextTableColumn(header: "Uploaded Date"),
            TextTableColumn(header: "Expiration Date"),
            TextTableColumn(header: "Expired")
            //TextTableColumn(header: "Uses Non Exempt Encryption"), - TODO ??
            //TextTableColumn(header: "Beta Groups"), - TODO ??
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            app?.attributes?.bundleId,
            app?.attributes?.name,
            attributes?.version,
            attributes?.processingState,
            attributes?.minOsVersion,
            attributes?.uploadedDate?.formattedDate,
            attributes?.expirationDate?.formattedDate,
            attributes?.expired?.toYesNo()
        ]
        .map { $0 ?? "" }
    }
}

