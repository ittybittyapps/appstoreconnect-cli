// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

import struct Model.App
import struct Model.BetaGroup

class AppStoreConnectService {
    private let provider: APIProvider
    private let requestor: EndpointRequestor

    init(configuration: APIConfiguration) {
        provider = APIProvider(configuration: configuration)
        requestor = DefaultEndpointRequestor(provider: provider)
    }

    func listUsers(with options: ListUsersOptions) -> AnyPublisher<[User], Error> {
        ListUsersOperation(options: options).execute(with: requestor)
    }

    func getUserInfo(with options: GetUserInfoOptions) -> AnyPublisher<User, Error> {
        GetUserInfoOperation(options: options).execute(with: requestor)
    }

    func listCertificates(with options: ListCertificatesOptions) -> AnyPublisher<[Certificate], Error> {
        ListCertificatesOperation(options: options).execute(with: requestor)
    }

    func readCertificate(serial: String) throws -> Certificate {
        let sdkCertificate = try ReadCertificateOperation(options: .init(serial: serial))
            .execute(with: requestor)
            .await()

        return Certificate(sdkCertificate)
    }

    func createCertificate(with options: CreateCertificateOptions) -> AnyPublisher<Certificate, Error> {
        CreateCertificateOperation(options: options).execute(with: requestor)
    }

    func revokeCertificates(serials: [String]) throws {
        let certificatesIds = try serials.map {
            try ReadCertificateOperation(options: .init(serial: $0))
                .execute(with: requestor)
                .await()
                .id
        }

        _ = try RevokeCertificatesOperation(options: .init(ids: certificatesIds))
            .execute(with: requestor)
            .awaitMany()
    }

    func inviteBetaTesterToGroups(with options: InviteBetaTesterOptions) throws -> BetaTester {
        let id = try InviteTesterOperation(options: options)
            .execute(with: requestor)
            .await()
            .id

        let output = try GetBetaTesterOperation(
                options: .init(identifier: .id(id))
            )
            .execute(with: requestor)
            .await()

        return BetaTester(output)
    }

    func addTestersToGroup(
        bundleId: String,
        groupName: String,
        emails: [String]
    ) throws {
        let testerIds = try emails.map {
            try GetBetaTesterOperation(options: .init(identifier: .email($0)))
                .execute(with: requestor)
                .await()
                .betaTester
                .id
        }

        let app = try ReadAppOperation(options: .init(identifier: .bundleId(bundleId)))
            .execute(with: requestor)
            .await()

        let groupId = try GetBetaGroupOperation(
                options: .init(app: app, betaGroupName: groupName)
            )
            .execute(with: requestor)
            .await()
            .id

        try AddTesterToGroupOperation(
                options: .init(
                    addStrategy: .addTestersToGroup(testerIds: testerIds, groupId: groupId)
                )
            )
            .execute(with: requestor)
            .await()
    }

    func addTesterToGroups(
        email: String,
        bundleId: String,
        groupNames: [String]
    ) throws {
        let testerId = try GetBetaTesterOperation(options: .init(identifier: .email(email)))
            .execute(with: requestor)
            .await()
            .betaTester
            .id

        let app = try ReadAppOperation(options: .init(identifier: .bundleId(bundleId)))
            .execute(with: requestor)
            .await()

        let groupIds = try groupNames.map {
            try GetBetaGroupOperation(
                    options: .init(app: app, betaGroupName: $0)
                )
                .execute(with: requestor)
                .await()
                .id
        }

        try AddTesterToGroupOperation(
                options: .init(
                    addStrategy: .addTesterToGroups(testerId: testerId, groupIds: groupIds)
                )
            )
            .execute(with: requestor)
            .await()
    }

    func getBetaTester(
        email: String,
        limitApps: Int?,
        limitBuilds: Int?,
        limitBetaGroups: Int?
    ) throws -> BetaTester {
        let operation = GetBetaTesterOperation(
            options: .init(
                identifier: .email(email),
                limitApps: limitApps,
                limitBuilds: limitBuilds,
                limitBetaGroups: limitBetaGroups
            )
        )

        let output = try operation.execute(with: requestor).await()

        return BetaTester(output)
    }

    func deleteBetaTesters(emails: [String]) throws -> [Void] {
        let requests = try emails.map {
            try GetBetaTesterOperation(
                    options: .init(identifier: .email($0))
                )
                .execute(with: requestor)
        }

        let ids = try Publishers.ConcatenateMany(requests).awaitMany().map(\.betaTester.id)

        return try DeleteBetaTestersOperation(options: .init(ids: ids))
            .execute(with: requestor)
            .awaitMany()
    }

    func listBetaTesters(
        email: String?,
        firstName: String?,
        lastName: String?,
        inviteType: BetaInviteType?,
        appIds: [String],
        bundleIds: [String],
        groupNames: [String],
        sort: ListBetaTesters.Sort?,
        limit: Int?,
        relatedResourcesLimit: Int?
    ) throws -> [BetaTester] {

        var appIds: [String] = appIds
        if !bundleIds.isEmpty && appIds.isEmpty {
            appIds = try GetAppsOperation(options: .init(bundleIds: bundleIds))
                .execute(with: requestor)
                .await()
                .map(\.id)
        }

        var groupIds: [String] = []
        if !groupNames.isEmpty {
            groupIds = try groupNames.map {
                try betaGroupIdentifier(matching: $0).await()
            }
        }

        return try ListBetaTestersOperation(options:
                .init(
                    email: email,
                    firstName: firstName,
                    lastName: lastName,
                    inviteType: inviteType,
                    appIds: appIds,
                    groupIds: groupIds,
                    sort: sort,
                    limit: limit,
                    relatedResourcesLimit: relatedResourcesLimit
                )
            )
            .execute(with: requestor)
            .await()
            .map(BetaTester.init)
    }

    func removeTesterFromGroups(email: String, groupNames: [String]) throws {
        let testerId = try GetBetaTesterOperation(
                options: .init(identifier: .email(email))
            )
            .execute(with: requestor)
            .await()
            .betaTester
            .id

        let groupIds = try groupNames.map { try betaGroupIdentifier(matching: $0).await() }

        let operation = RemoveTesterOperation(
            options: .init(
                removeStrategy: .removeTesterFromGroups(testerId: testerId, groupIds: groupIds)
            )
        )

        try operation.execute(with: requestor).await()
    }

    func removeTestersFromGroup(groupName: String, emails: [String]) throws {
        let groupId = try betaGroupIdentifier(matching: groupName).await()

        let testerIds = try emails.map {
            try GetBetaTesterOperation(
                    options: .init(identifier: .email($0))
                )
                .execute(with: requestor)
                .await()
                .betaTester
                .id
        }

        let operation = RemoveTesterOperation(
            options: .init(
                removeStrategy: .removeTestersFromGroup(testerIds: testerIds, groupId: groupId)
            )
        )

        try operation.execute(with: requestor).await()
    }

    func readBetaGroup(bundleId: String, groupName: String) throws -> BetaGroup {
        let app = try ReadAppOperation(options: .init(identifier: .bundleId(bundleId)))
            .execute(with: requestor)
            .await()

        let options = GetBetaGroupOperation.Options(app: app, betaGroupName: groupName)
        let betaGroup = try GetBetaGroupOperation(options: options)
            .execute(with: requestor)
            .await()

        return BetaGroup(app, betaGroup)
    }
        
    func createBetaGroup(
        appBundleId: String,
        groupName: String,
        publicLinkEnabled: Bool,
        publicLinkLimit: Int?
    ) throws -> BetaGroup {
        let getAppsOperation = GetAppsOperation(options: .init(bundleIds: [appBundleId]))
        let app = try getAppsOperation.execute(with: requestor).compactMap(\.first).await()

        let createBetaGroupOperation = CreateBetaGroupOperation(
            options: .init(
                app: app,
                groupName: groupName,
                publicLinkEnabled: publicLinkEnabled,
                publicLinkLimit: publicLinkLimit
            )
        )

        let betaGroupResponse = createBetaGroupOperation.execute(with: requestor)
        return try betaGroupResponse.map(BetaGroup.init).await()
    }

    func deleteBetaGroup(appBundleId: String, betaGroupName: String) throws {
        let app = try GetAppsOperation(options: .init(bundleIds: [appBundleId]))
            .execute(with: requestor)
            .compactMap(\.first)
            .await()

        let betaGroup = try GetBetaGroupOperation(
            options: .init(app: app, betaGroupName: betaGroupName))
            .execute(with: requestor)
            .await()

        try DeleteBetaGroupOperation(options: .init(betaGroupId: betaGroup.id))
            .execute(with: requestor)
            .await()
    }

    func listBetaGroups(bundleIds: [String], names: [String]) throws -> [BetaGroup] {
        let operation = GetAppsOperation(options: .init(bundleIds: bundleIds))
        let appIds = try operation.execute(with: requestor).await().map(\.id)

        return try listBetaGroups(appIds: appIds, names: names)
    }

    func listBetaGroups(appIds: [String], names: [String]) throws -> [BetaGroup] {
        let operation = ListBetaGroupsOperation(options: .init(appIds: appIds, names: names))

        return try operation.execute(with: requestor).await().map(BetaGroup.init)
    }

    func modifyBetaGroup(
        appBundleId: String,
        currentGroupName: String,
        newGroupName: String?,
        publicLinkEnabled: Bool?,
        publicLinkLimit: Int?,
        publicLinkLimitEnabled: Bool?
    ) throws -> BetaGroup {
        let getAppsOperation = GetAppsOperation(options: .init(bundleIds: [appBundleId]))
        let app = try getAppsOperation.execute(with: requestor).compactMap(\.first).await()

        let getBetaGroupOperation = GetBetaGroupOperation(
            options: .init(app: app, betaGroupName: currentGroupName))
        let betaGroup = try getBetaGroupOperation.execute(with: requestor).await()

        let modifyBetaGroupOptions = ModifyBetaGroupOperation.Options(
            betaGroup: betaGroup,
            betaGroupName: newGroupName,
            publicLinkEnabled: publicLinkEnabled,
            publicLinkLimit: publicLinkLimit,
            publicLinkLimitEnabled: publicLinkLimitEnabled)
        let modifyBetaGroupOperation = ModifyBetaGroupOperation(options: modifyBetaGroupOptions)
        let modifiedBetaGroup = try modifyBetaGroupOperation.execute(with: requestor).await()

        return BetaGroup(app, modifiedBetaGroup)
    }

    func readBuild(bundleId: String, buildNumber: String, preReleaseVersion: String) throws -> Build {
        let appsOperation = GetAppsOperation(options: .init(bundleIds: [bundleId]))
        let appId = try appsOperation.execute(with: requestor).compactMap(\.first).await().id

        let readBuildOperation = ReadBuildOperation(options: .init(appId: appId, buildNumber: buildNumber, preReleaseVersion: preReleaseVersion))

        let output = try readBuildOperation.execute(with: requestor).await()
        return Build(output.build, output.relationships)
    }

    func expireBuild(bundleId: String, buildNumber: String, preReleaseVersion: String) throws -> Void {
        let appsOperation = GetAppsOperation(options: .init(bundleIds: [bundleId]))
        let appId = try appsOperation.execute(with: requestor).compactMap(\.first).await().id

        let readBuildOperation = ReadBuildOperation(options: .init(appId: appId, buildNumber: buildNumber, preReleaseVersion: preReleaseVersion))
        let buildId = try readBuildOperation.execute(with: requestor).await().build.id

        let expireBuildOperation = ExpireBuildOperation(options: .init(buildId: buildId))
        _ = try expireBuildOperation.execute(with: requestor).await()
    }

    func listBuilds(
        filterBundleIds: [String],
        filterExpired: [String],
        filterPreReleaseVersions: [String],
        filterBuildNumbers: [String],
        filterProcessingStates:[ListBuilds.Filter.ProcessingState],
        filterBetaReviewStates: [String],
        limit: Int?
    ) throws -> [Build] {

        var filterAppIds: [String] = []

        if !filterBundleIds.isEmpty {
            let appsOperation = GetAppsOperation(options: .init(bundleIds: filterBundleIds))
            filterAppIds = try appsOperation.execute(with: requestor).await().map(\.id)
        }

        let listBuildsOperation = ListBuildsOperation(
            options: .init(
                filterAppIds: filterAppIds,
                filterExpired: filterExpired,
                filterPreReleaseVersions: filterPreReleaseVersions,
                filterBuildNumbers: filterBuildNumbers,
                filterProcessingStates: filterProcessingStates,
                filterBetaReviewStates: filterBetaReviewStates,
                limit: limit
            )
        )

        let output = try listBuildsOperation.execute(with: requestor).await()
        return output.map(Build.init)
    }

    func removeBuildFromGroups(
        bundleId: String,
        version: String,
        buildNumber: String,
        groupNames: [String]
    ) throws {
        let (buildId, groupIds) = try getBuildIdAndGroupIdsFrom(
            bundleId: bundleId,
            version: version,
            buildNumber: buildNumber,
            groupNames: groupNames
        )

        try RemoveBuildFromGroupsOperation(options: .init(buildId: buildId, groupIds: groupIds))
            .execute(with: requestor)
            .await()
    }

    func addGroupsToBuild(
        bundleId: String,
        version: String,
        buildNumber: String,
        groupNames: [String]
    ) throws {
        let (buildId, groupIds) = try getBuildIdAndGroupIdsFrom(
            bundleId: bundleId,
            version: version,
            buildNumber: buildNumber,
            groupNames: groupNames
        )

        try AddGroupsToBuildOperation(options: .init(groupIds: groupIds, buildId: buildId))
            .execute(with: requestor)
            .await()
    }

    func readApp(identifier: ReadAppCommand.Identifier) throws -> App {
        let sdkApp = try ReadAppOperation(options: .init(identifier: identifier))
            .execute(with: requestor)
            .await()

        return App(sdkApp)
    }

    func listPreReleaseVersions(
        filterIdentifiers: [ListPreReleaseVersionsCommand.Identifier],
        filterVersions: [String],
        filterPlatforms: [String],
        sort: ListPrereleaseVersions.Sort?
    ) throws -> [PreReleaseVersion] {

        var filterAppIds: [String] = []
        var filterBundleIds: [String] = []

        _ = filterIdentifiers.map { identifier in
            switch (identifier) {
            case .appId(let filterAppId):
                filterAppIds.append(filterAppId)  
            case .bundleId(let filterBundleId):
                filterBundleIds.append(filterBundleId)
            }
        }

        if !filterBundleIds.isEmpty {
            let appsOperation = GetAppsOperation(options: .init(bundleIds: filterBundleIds))
            filterAppIds += try appsOperation.execute(with: requestor).await().map(\.id)
        }

        let listpreReleaseVersionsOperation = ListPreReleaseVersionsOperation(
            options: .init(
                filterAppIds: filterAppIds,
                filterVersions: filterVersions,
                filterPlatforms: filterPlatforms,
                sort: sort)
        )

        let output = try listpreReleaseVersionsOperation.execute(with: requestor).await()
        return output.map(PreReleaseVersion.init)
    }


    func readPreReleaseVersion(appId: String) throws -> PreReleaseVersionDetails {
        let readPreReleaseVersionOperation = ReadPreReleaseVersionOperation(options: .init(appId: appId))

        let output = try readPreReleaseVersionOperation.execute(with: requestor).await()
        return PreReleaseVersionDetails(output.preReleaseVersion, output.relationships)
     }

     func readPreReleaseVersion(bundleId: String) throws -> PreReleaseVersionDetails {
        let appsOperation = GetAppsOperation(options: .init(bundleIds: [bundleId]))
        let appId = try appsOperation.execute(with: requestor).compactMap(\.first).await().id

        let readPreReleaseVersionOperation = ReadPreReleaseVersionOperation(options: .init(appId: appId))
        let output = try readPreReleaseVersionOperation.execute(with: requestor).await()
        return PreReleaseVersionDetails(output.preReleaseVersion, output.relationships)
     }




    /// Make a request for something `Decodable`.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    /// - Returns: `Future<T, Error>` that executes immediately (hot observable)
    func request<T: Decodable>(_ endpoint: APIEndpoint<T>) -> Future<T, Error> {
        Future { [provider] promise in
            provider.request(endpoint, completion: promise)
        }
    }

    /// Make a request which does not return anything (ie. returns `Void`) when successful.
    ///
    /// - Parameters:
    ///   - endpoint: The API endpoint to request
    /// - Returns: `Future<Void, Error>` that executes immediately (hot observable)
    func request(_ endpoint: APIEndpoint<Void>) -> Future<Void, Error> {
        Future { [provider] promise in
            provider.request(endpoint, completion: promise)
        }
    }
}

extension AppStoreConnectService {

    func getBuildIdAndGroupIdsFrom(
        bundleId: String,
        version: String,
        buildNumber: String,
        groupNames: [String]
    ) throws -> (buildId: String, groupIds: [String]) {
        let appId = try ReadAppOperation(options: .init(identifier: .bundleId(bundleId)))
            .execute(with: requestor)
            .await()
            .id

        let buildId = try ReadBuildOperation(
                options: .init(
                    appId: appId,
                    buildNumber: buildNumber,
                    preReleaseVersion: version
                )
            )
            .execute(with: requestor)
            .await()
            .build
            .id
        let groupIds = try ListBetaGroupsOperation(options: .init(appIds: [], names: []))
            .execute(with: requestor)
            .await()
            .filter {
                guard let groupName = $0.betaGroup.attributes?.name else {
                    return false
                }
                return $0.app.id == appId && groupNames.contains(groupName)
            }
            .map(\.betaGroup.id)

        return (buildId, groupIds)
    }

}
