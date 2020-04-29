// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation
import SwiftyTextTable

struct PreReleaseVersion: Codable {
    var app: App
    var platform: Platform
    var version: String
    // TODO: var builds: [Build]?
}

extension PreReleaseVersion {
    init(_ prereleaseVersion: AppStoreConnect_Swift_SDK.PrereleaseVersion, app: AppStoreConnect_Swift_SDK.App? = nil, builds: [AppStoreConnect_Swift_SDK.Build]? = nil) {
        self.init(prereleaseVersion.attributes!, app: app, buildAttributes: builds?.map { $0.attributes! } )
    }

    init(
        _ attributes: AppStoreConnect_Swift_SDK.PrereleaseVersion.Attributes,
        app: AppStoreConnect_Swift_SDK.App?,
        buildAttributes: [AppStoreConnect_Swift_SDK.Build.Attributes]?
    ) {
        self.init(
            app: app.map(App.init)!,
            platform: attributes.platform!,
            version: attributes.version!
            // TODO: builds: buildAttributes?.map(Build.init)
        )
    }
}

extension Array where Element == PreReleaseVersion {
    init(_ response: AppStoreConnect_Swift_SDK.PreReleaseVersionsResponse) {
        let apps = response.included?.apps
         let builds = response.included?.builds

        let items: [PreReleaseVersion] = response.data.map { version in
            let buildIds = Set(version.relationships?.builds?.data.map { $0.map(\.id) } ?? [])

            return PreReleaseVersion(
                version,
                app: apps?.first { $0.id == version.relationships?.app?.data?.id },
                builds: builds?.filter { buildIds.contains($0.id) }
            )
        }

        self.init(items)
    }
}

private extension Array where Element == PreReleaseVersionRelationship {
    var apps: [AppStoreConnect_Swift_SDK.App] {
        compactMap { $0.app }
    }

    var builds: [AppStoreConnect_Swift_SDK.Build] {
        compactMap { $0.build }
    }
}

private extension PreReleaseVersionRelationship {
    var app: AppStoreConnect_Swift_SDK.App? {
        guard case .app(let app) = self else {
            return nil

        }
        return app
    }

    var build: AppStoreConnect_Swift_SDK.Build? {
        guard case .build(let build) = self else {
            return nil

        }
        return build
    }
}

extension PreReleaseVersion: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
        return [
            TextTableColumn(header: "App ID"),
            TextTableColumn(header: "App Bundle ID"),
            TextTableColumn(header: "App Name"),
            TextTableColumn(header: "Platform"),
            TextTableColumn(header: "Version"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
            app.id,
            app.bundleId,
            app.name,
            platform.description,
            version
        ].map { $0 ?? "" }
    }
}
