// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import class Bagbutik.BagbutikService
import struct Bagbutik.JWT
import Combine
import CollectionConcurrencyKit
import Foundation
import Model

class AppStoreConnectService {

    private let service: BagbutikService
    private let provider: APIProvider
    private let requestor: EndpointRequestor

    init(configuration: APIConfiguration, jwt: JWT) {
        service = BagbutikService(jwt: jwt)
        provider = APIProvider(configuration: configuration)
        requestor = DefaultEndpointRequestor(provider: provider)
    }
    
    /// Find the opaque internal identifier for an application that related to this bundle ID.
    func appResourceIdsForBundleIds(_ bundleIds: [String]) async throws -> [String] {
        return try await service.requestAllPages(.listAppsV1(filters: [.bundleId(bundleIds)])).data.map(\.id)
    }
    
    func listApps(
        bundleIds: [String] = [],
        names: [String] = [],
        skus: [String] = [],
        limit: Int? = nil
    ) async throws -> [Model.App] {
        let operation = ListAppsOperation(
            options: .init(bundleIds: bundleIds, names: names, skus: skus, limit: limit)
        )

        return try await operation.execute(with: service).map { Model.App.init($0) }
    }

    func listBundleIds(
        identifiers: [String],
        names: [String],
        platforms: [String],
        seedIds: [String],
        limit: Int?
    ) async throws -> [Model.BundleId] {
        let operation = ListBundleIdsOperation(options:
            .init(
                identifiers: identifiers,
                names: names,
                platforms: platforms,
                seedIds: seedIds,
                limit: limit
            )
        )

        return try await operation.execute(with: service).map { Model.BundleId.init($0) }            
    }

    func listUsers(
        limitVisibleApps: Int?,
        limitUsers: Int?,
        sort: String?,
        filterUsername: [String],
        filterRole: [Model.UserRole],
        filterVisibleApps: [AppLookupIdentifier],
        includeVisibleApps: Bool
    ) async throws -> [Model.User] {
        let appIds = try await filterVisibleApps.asyncMap { identifier -> String in
            switch identifier {
            case .appId(let appid):
                return appid
            case .bundleId(let bundleId):
                return try await ReadAppOperation(options: .init(identifier: .bundleId(bundleId)))
                    .execute(with: service)
                    .id
            }
        }

        return try await ListUsersOperation(
            options: .init(
                limitVisibleApps: limitVisibleApps,
                limitUsers: limitUsers,
                sort: sort,
                filterUsername: filterUsername,
                filterRole: filterRole.map(\.rawValue),
                filterVisibleApps: appIds,
                includeVisibleApps: includeVisibleApps
            )
        )
        .execute(with: service)
        .map { .init($0) }
    }

    func userInfo(with email: String, includeVisibleApps: Bool) throws -> Model.User {
        try GetUserInfoOperation(
            options: .init(
                email: email,
                includeVisibleApps: includeVisibleApps
            )
        )
        .execute(with: requestor)
        .compactMap(Model.User.fromAPIUser)
        .await()
    }

    func modifyUserInfo(
        email: String,
        roles: [Model.UserRole],
        allAppsVisible: Bool,
        provisioningAllowed: Bool,
        bundleIds: [String]
    ) throws -> Model.User {
        let userId = try GetUserInfoOperation(options: .init(email: email, includeVisibleApps: false))
            .execute(with: requestor)
            .await()
            .id

        return try ModifyUserOperation(
            options: .init(
                userId: userId,
                allAppsVisible: allAppsVisible,
                provisioningAllowed: provisioningAllowed,
                roles: roles.map { .init($0) },
                appsVisibleIds: bundleIds
            )
        )
        .execute(with: requestor)
        .compactMap(Model.User.fromAPIUser)
        .await()
    }

    func listCertificates(
        filterSerial: String?,
        sort: Certificates.Sort?,
        filterType: CertificateType?,
        filterDisplayName: String?,
        limit: Int?
    ) throws -> [Model.Certificate] {
        try ListCertificatesOperation(
                options: .init(
                    filterSerial: filterSerial,
                    sort: sort,
                    filterType: filterType,
                    filterDisplayName: filterDisplayName,
                    limit: limit
                )
            )
            .execute(with: requestor)
            .await()
            .map(Model.Certificate.init)
    }

    func readCertificate(serial: String) throws -> Model.Certificate {
        let sdkCertificate = try ReadCertificateOperation(options: .init(serial: serial))
            .execute(with: requestor)
            .await()

        return Model.Certificate(sdkCertificate)
    }

    func createCertificate(
        certificateType: CertificateType,
        csrContent: String
    ) throws -> Model.Certificate {
        try CreateCertificateOperation(
                options: .init(certificateType: certificateType, csrContent: csrContent)
            )
            .execute(with: requestor)
            .await()
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

    func inviteBetaTesterToGroups(
        firstName: String?,
        lastName: String?,
        email: String,
        bundleId: String,
        groupNames: [String]
    ) throws -> Model.BetaTester {
        let id = try InviteTesterOperation(
                options: .init(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    identifers: .bundleIdWithGroupNames(bundleId: bundleId, groupNames: groupNames)
                )
            )
            .execute(with: requestor)
            .await()
            .id

        let output = try GetBetaTesterOperation(
                options: .init(identifier: .id(id))
            )
            .execute(with: requestor)
            .await()

        return Model.BetaTester(output)
    }

    func addTestersToGroup(
        bundleId: String,
        groupName: String,
        emails: [String]
    ) async throws {
        let testerIds = try emails.map {
            try GetBetaTesterOperation(options: .init(identifier: .email($0)))
                .execute(with: requestor)
                .await()
                .betaTester
                .id
        }

        let app = try await ReadAppOperation(options: .init(identifier: .bundleId(bundleId)))
            .execute(with: service)

        let groupId = try GetBetaGroupOperation(
                options: .init(appId: app.id, bundleId: bundleId, betaGroupName: groupName)
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
    ) async throws {
        let testerId = try GetBetaTesterOperation(options: .init(identifier: .email(email)))
            .execute(with: requestor)
            .await()
            .betaTester
            .id

        let app = try await ReadAppOperation(options: .init(identifier: .bundleId(bundleId)))
            .execute(with: service)

        let groupIds = try groupNames.map {
            try GetBetaGroupOperation(
                options: .init(appId: app.id, bundleId: bundleId, betaGroupName: $0)
            )
            .execute(with: requestor)
            .await()
            .id
        }

        try AddTesterToGroupOperation(
            options: .init(addStrategy: .addTesterToGroups(testerId: testerId, groupIds: groupIds))
        )
        .execute(with: requestor)
        .await()
    }

    func getBetaTester(
        email: String,
        limitApps: Int?,
        limitBuilds: Int?,
        limitBetaGroups: Int?
    ) throws -> Model.BetaTester {
        let operation = GetBetaTesterOperation(
            options: .init(
                identifier: .email(email),
                limitApps: limitApps,
                limitBuilds: limitBuilds,
                limitBetaGroups: limitBetaGroups
            )
        )

        let output = try operation.execute(with: requestor).await()

        return Model.BetaTester(output)
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
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        inviteType: BetaInviteType? = nil,
        filterIdentifiers: [AppLookupIdentifier] = [],
        groupNames: [String] = [],
        sort: ListBetaTesters.Sort? = nil,
        limit: Int? = nil,
        relatedResourcesLimit: Int? = nil
    ) throws -> [Model.BetaTester] {

        var filterAppIds: [String] = []
        var filterBundleIds: [String] = []

        filterIdentifiers.forEach { identifier in
            switch identifier {
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

        var groupIds: [String] = []
        if !groupNames.isEmpty {
            groupIds = try groupNames.flatMap {
                try ListBetaGroupsOperation(options: .init(appIds: [], names: [$0], sort: nil))
                    .execute(with: requestor)
                    .await()
                    .map { $0.betaGroup.id }
            }
        }

        let operation = ListBetaTestersOperation(
            options: .init(
                email: email,
                firstName: firstName,
                lastName: lastName,
                inviteType: inviteType,
                appIds: nil, // Specifying app ids in the API request can cause undefined behaviour
                groupIds: groupIds,
                sort: sort,
                limit: limit,
                relatedResourcesLimit: relatedResourcesLimit
            )
        )

        var betaTesters = try operation.execute(with: requestor).await()

        if filterAppIds.isEmpty == false {
            betaTesters = betaTesters.filter { betaTester in
                betaTester.apps?.first(where: { app in filterAppIds.contains(app.id) }) != nil
            }
        }

        return betaTesters.map(Model.BetaTester.init)
    }

    func listBetaTestersForGroup(
        identifier: AppLookupIdentifier,
        groupName: String
    ) async throws -> [Model.BetaTester] {
        let readAppOperation = ReadAppOperation(options: .init(identifier: identifier))
        let app = try await readAppOperation.execute(with: service)

        let getBetaGroupOperation = GetBetaGroupOperation(
            options: .init(appId: app.id, bundleId: nil, betaGroupName: groupName)
        )
        let betaGroup = try getBetaGroupOperation.execute(with: requestor).await()

        let operation = ListBetaTestersByGroupOperation(options: .init(groupId: betaGroup.id))
        let output = try operation.execute(with: requestor).await()

        return output.map { apiBetaTester -> Model.BetaTester in
            Model.BetaTester(
                email: apiBetaTester.attributes?.email,
                firstName: apiBetaTester.attributes?.firstName,
                lastName: apiBetaTester.attributes?.lastName,
                inviteType: (apiBetaTester.attributes?.inviteType).map { $0.rawValue },
                betaGroups: [Model.BetaGroup(app, betaGroup)],
                apps: [Model.App(app)]
            )
        }
    }

    func removeTesterFromGroups(email: String, groupNames: [String]) throws {
        let testerId = try GetBetaTesterOperation(
                options: .init(identifier: .email(email))
            )
            .execute(with: requestor)
            .await()
            .betaTester
            .id

        let groupIds = try groupNames.flatMap {
            try ListBetaGroupsOperation(options: .init(appIds: [], names: [$0], sort: nil))
                .execute(with: requestor)
                .await()
                .map { $0.betaGroup.id }
        }

        let operation = RemoveTesterOperation(
            options: .init(
                removeStrategy: .removeTesterFromGroups(testerId: testerId, groupIds: groupIds)
            )
        )

        try operation.execute(with: requestor).await()
    }

    func removeTestersFromGroup(groupName: String, emails: [String]) throws {
        let groupId = try GetBetaGroupOperation(
            options: .init(appId: nil, bundleId: nil, betaGroupName: groupName)
        )
        .execute(with: requestor)
        .await()
        .id

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

    func readBetaGroup(bundleId: String, groupName: String) async throws -> Model.BetaGroup {
        let app = try await ReadAppOperation(options: .init(identifier: .bundleId(bundleId)))
            .execute(with: service)

        let options = GetBetaGroupOperation.Options(appId: app.id, bundleId: bundleId, betaGroupName: groupName)
        let betaGroup = try GetBetaGroupOperation(options: options)
            .execute(with: requestor)
            .await()

        return Model.BetaGroup(app, betaGroup)
    }

    func createBetaGroup(
        appBundleId: String,
        groupName: String,
        publicLinkEnabled: Bool,
        publicLinkLimit: Int?
    ) throws -> Model.BetaGroup {
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
        return try betaGroupResponse.map(Model.BetaGroup.init).await()
    }

    func deleteBetaGroup(appBundleId: String, betaGroupName: String) throws {
        let appId = try GetAppsOperation(options: .init(bundleIds: [appBundleId]))
            .execute(with: requestor)
            .compactMap(\.first)
            .await()
            .id

        let betaGroup = try GetBetaGroupOperation(
                options: .init(appId: appId, bundleId: appBundleId, betaGroupName: betaGroupName)
            )
            .execute(with: requestor)
            .await()

        try DeleteBetaGroupOperation(options: .init(betaGroupId: betaGroup.id))
            .execute(with: requestor)
            .await()
    }

    func listBetaGroups(
        filterIdentifiers: [AppLookupIdentifier] = [],
        names: [String] = [],
        sort: ListBetaGroups.Sort? = nil,
        excludeInternal: Bool = false
    ) throws -> [Model.BetaGroup] {
        var filterAppIds: [String] = []
        var filterBundleIds: [String] = []

        filterIdentifiers.forEach { identifier in
            switch identifier {
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

        let operation = ListBetaGroupsOperation(
            options: .init(appIds: filterAppIds, names: names, sort: sort, excludeInternal: excludeInternal)
        )

        return try operation.execute(with: requestor).await().map(Model.BetaGroup.init)
    }

    func modifyBetaGroup(
        appBundleId: String,
        currentGroupName: String,
        newGroupName: String?,
        publicLinkEnabled: Bool?,
        publicLinkLimit: Int?,
        publicLinkLimitEnabled: Bool?
    ) throws -> Model.BetaGroup {
        let getAppsOperation = GetAppsOperation(options: .init(bundleIds: [appBundleId]))
        let app = try getAppsOperation.execute(with: requestor).compactMap(\.first).await()

        let getBetaGroupOperation = GetBetaGroupOperation(
            options: .init(appId: app.id, bundleId: appBundleId, betaGroupName: currentGroupName))
        let betaGroup = try getBetaGroupOperation.execute(with: requestor).await()

        let modifyBetaGroupOptions = ModifyBetaGroupOperation.Options(
            betaGroup: betaGroup,
            betaGroupName: newGroupName,
            publicLinkEnabled: publicLinkEnabled,
            publicLinkLimit: publicLinkLimit,
            publicLinkLimitEnabled: publicLinkLimitEnabled)
        let modifyBetaGroupOperation = ModifyBetaGroupOperation(options: modifyBetaGroupOptions)
        let modifiedBetaGroup = try modifyBetaGroupOperation.execute(with: requestor).await()

        return Model.BetaGroup(app, modifiedBetaGroup)
    }

    func readBuild(bundleId: String, buildNumber: String, preReleaseVersion: String) throws -> Model.Build {
        let appsOperation = GetAppsOperation(options: .init(bundleIds: [bundleId]))
        let appId = try appsOperation.execute(with: requestor).compactMap(\.first).await().id

        let readBuildOperation = ReadBuildOperation(options: .init(appId: appId, buildNumber: buildNumber, preReleaseVersion: preReleaseVersion))

        let output = try readBuildOperation.execute(with: requestor).await()
        return Model.Build(output.build, output.relationships)
    }

    func expireBuild(bundleId: String, buildNumber: String, preReleaseVersion: String) throws {
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
        filterProcessingStates: [ListBuilds.Filter.ProcessingState],
        filterBetaReviewStates: [String],
        limit: Int?
    ) throws -> [Model.Build] {

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
        return output.map(Model.Build.init)
    }

    func removeBuildFromGroups(
        bundleId: String,
        version: String,
        buildNumber: String,
        groupNames: [String]
    ) async throws {
        let (buildId, groupIds) = try await buildIdAndGroupIdsFrom(
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
    ) async throws {
        let (buildId, groupIds) = try await buildIdAndGroupIdsFrom(
            bundleId: bundleId,
            version: version,
            buildNumber: buildNumber,
            groupNames: groupNames
        )

        try AddGroupsToBuildOperation(options: .init(groupIds: groupIds, buildId: buildId))
            .execute(with: requestor)
            .await()
    }

    func readApp(identifier: AppLookupIdentifier) async throws -> Model.App {
        let app = try await ReadAppOperation(options: .init(identifier: identifier))
            .execute(with: service)

        return Model.App(app)
    }

    func listPreReleaseVersions(
        filterIdentifiers: [AppLookupIdentifier],
        filterVersions: [String],
        filterPlatforms: [String],
        sort: ListPrereleaseVersions.Sort?
    ) throws -> [PreReleaseVersion] {

        var filterAppIds: [String] = []
        var filterBundleIds: [String] = []

        filterIdentifiers.forEach { identifier in
            switch identifier {
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

    func readPreReleaseVersion(filterIdentifier: AppLookupIdentifier, filterVersion: String) throws -> PreReleaseVersion {
        var filterAppId: String = ""

        switch filterIdentifier {
        case .appId(let appId):
            filterAppId = appId
        case .bundleId(let bundleId):
            let appsOperation = GetAppsOperation(options: .init(bundleIds: [bundleId]))
            filterAppId = try appsOperation.execute(with: requestor).compactMap(\.first).await().id
        }

        let readPreReleaseVersionOperation = ReadPreReleaseVersionOperation(options: .init(filterAppId: filterAppId, filterVersion: filterVersion))
        let output = try readPreReleaseVersionOperation.execute(with: requestor).await()
        return PreReleaseVersion(output.preReleaseVersion, output.relationships)
    }

    func listDevices(
        filterName: [String],
        filterPlatform: [Platform],
        filterUDID: [String],
        filterStatus: DeviceStatus?,
        sort: Devices.Sort?,
        limit: Int?
    ) throws -> [Model.Device] {
        try ListDevicesOperation(
                options: .init(
                    filterName: filterName,
                    filterPlatform: filterPlatform,
                    filterUDID: filterUDID,
                    filterStatus: filterStatus,
                    sort: sort,
                    limit: limit
                )
            )
            .execute(with: requestor)
            .await()
            .map(Device.init)
    }

    func listProfilesByBundleId(_ bundleId: String, limit: Int?) async throws -> [Model.Profile] {
        let bundleIdResourceIds = try await ListBundleIdsOperation(
            options: .init(identifiers: [bundleId], names: [], platforms: [], seedIds: [], limit: nil)
        )
        .execute(with: service)
        .filter { ($0.attributes?.identifier?.starts(with: bundleId) ?? false) }
        .map(\.id)

        return try bundleIdResourceIds.map {
            try ListProfilesByBundleIdOperation(
                options: .init(bundleIdResourceId: $0, limit: limit)
            )
            .execute(with: requestor)
            .await()
        }
        .flatMap { $0 }
        .map(Model.Profile.init)
    }

    func readProfile(id: String) throws -> Model.Profile {
        Model.Profile(
            try ReadProfileOperation(options: .init(id: id))
                .execute(with: requestor)
                .await()
        )
    }

    func listProfiles(
        ids: [String],
        filterName: [String],
        filterProfileState: ProfileState?,
        filterProfileType: [ProfileType],
        sort: Profiles.Sort?,
        limit: Int?
    ) throws -> [Model.Profile] {
        try ListProfilesOperation(
            options: .init(
                ids: ids,
                filterName: filterName,
                filterProfileState: filterProfileState,
                filterProfileType: filterProfileType,
                sort: sort,
                limit: limit
            )
        )
        .execute(with: requestor)
        .await()
        .map(Model.Profile.init)
    }

    func createProfile(
        name: String,
        bundleId: String,
        profileType: ProfileType,
        certificateSerialNumbers: [String],
        deviceUDIDs: [String]
    ) async throws -> Model.Profile {
        let bundleIdResourceId = try await ReadBundleIdOperation(
            service: service,
            options: .init(bundleId: bundleId)
        )
        .execute()
        .id

        let deviceIds = try ListDevicesOperation(
            options: .init(
                filterName: [],
                filterPlatform: [],
                filterUDID: deviceUDIDs,
                filterStatus: nil,
                sort: nil,
                limit: nil
            )
        )
        .execute(with: requestor)
        .await()
        .map { $0.id }

        let certificateIds = try certificateSerialNumbers.compactMap {
            try ListCertificatesOperation(
                options: .init(
                    filterSerial: $0,
                    sort: nil,
                    filterType: nil,
                    filterDisplayName: nil,
                    limit: nil
                )
            )
            .execute(with: requestor)
            .await()
            .first?
            .id
        }

        return try CreateProfileOperation(
            options: .init(
                name: name,
                bundleId: bundleIdResourceId,
                profileType: profileType,
                certificateIds: certificateIds,
                deviceIds: deviceIds
            )
        )
        .execute(with: requestor)
        .map(Model.Profile.init)
        .await()
    }

    func listUserInvitaions(
        filterEmail: [String],
        filterRole: [Model.UserRole],
        limitVisibleApps: Int?,
        includeVisibleApps: Bool
    ) async throws -> [Model.UserInvitation] {
        try await ListUserInvitationsOperation(
                options: .init(
                    filterEmail: filterEmail,
                    filterRole: filterRole.map { .init($0) },
                    includeVisibleApps: includeVisibleApps,
                    limitVisibleApps: limitVisibleApps
                )
            )
            .execute(with: service)
            .map {
                UserInvitation($0)
            }
    }

    /// Find the opaque internal identifier for this invitation; search by email address.
    ///
    /// This is an App Store Connect internal identifier
    func invitationIdentifier(matching email: String) async throws -> String {
        let invitations = try await service.request(.listUserInvitationsV1(filters: [.email([email])]))
            .data
        
        guard let invitation = invitations.first(where: { $0.attributes?.email == email }) else {
            // FIXME: should throw
            fatalError("User with email address '\(email)' not unique or not found")
        }
        
        return invitation.id
    }
    
    func cancel(userInvitationWithId identifier: String) async throws {
        let _ = try await service.request(.deleteUserInvitationV1(id: identifier))        
    }

    func inviteUserToTeam(
        email: String,
        firstName: String,
        lastName: String,
        roles: [Model.UserRole],
        allAppsVisible: Bool,
        provisioningAllowed: Bool,
        appsVisibleIds: [String] = []
    ) async throws -> Model.UserInvitation {
        
        // appsVisibleIds should be empty when allAppsVisible is true
        precondition(allAppsVisible && appsVisibleIds.isEmpty)
                      
        let invitation = try await service.request(
            .createUserInvitationV1(
                requestBody: .init(
                    data: .init(
                        attributes: .init(
                            allAppsVisible: allAppsVisible,
                            email: email,
                            firstName: firstName,
                            lastName: lastName,
                            provisioningAllowed: provisioningAllowed,
                            roles: roles.map { .init($0) }
                        )
                    )
                )
            )
        ).data
        
        return .init(invitation)
    }
    
    func downloadSales(
        frequency: [DownloadSalesAndTrendsReports.Filter.Frequency],
        reportType: [DownloadSalesAndTrendsReports.Filter.ReportType],
        reportSubType: [DownloadSalesAndTrendsReports.Filter.ReportSubType],
        vendorNumber: [String],
        reportDate: [String],
        version: [String]
    ) throws -> Data {
        try DownloadSalesOperation(options: .init(
                frequency: frequency,
                reportType: reportType,
                reportSubType: reportSubType,
                vendorNumber: vendorNumber,
                reportDate: reportDate,
                version: version)
            )
            .execute(with: requestor)
            .await()
    }

    func downloadFinanceReports(
        regionCode: DownloadFinanceReports.RegionCode,
        reportDate: String,
        vendorNumber: String
    ) throws -> Data {
        try DownloadFinanceReportsOperation(
                options: .init(
                    regionCode: [regionCode],
                    reportDate: reportDate,
                    vendorNumber: vendorNumber
                )
            )
            .execute(with: requestor)
            .await()
    }

    func listBuildsLocalizations(
        bundleId: String,
        buildNumber: String,
        preReleaseVersion: String,
        limit: Int?
    ) async throws -> [BuildLocalization] {
        let buildId = try await buildIdFrom(
            bundleId: bundleId,
            buildNumber: buildNumber,
            preReleaseVersion: preReleaseVersion
        )

        return try ListBuildLocalizationOperation(
            options: .init(id: buildId, limit: limit)
        )
        .execute(with: requestor)
        .await()
        .map(BuildLocalization.init)
    }

    func readBuildLocaization(
        bundleId: String,
        buildNumber: String,
        preReleaseVersion: String,
        locale: String
    ) async throws -> BuildLocalization {
        let buildId = try await buildIdFrom(
            bundleId: bundleId,
            buildNumber: buildNumber,
            preReleaseVersion: preReleaseVersion
        )

        return BuildLocalization(
            try ReadBuildLocalizationOperation(
                options: .init(id: buildId, locale: locale)
            )
            .execute(with: requestor)
            .await()
        )
    }

    func deleteBuildLocalization(
        bundleId: String,
        buildNumber: String,
        preReleaseVersion: String,
        locale: String
    ) async throws {
        let buildId = try await buildIdFrom(
            bundleId: bundleId,
            buildNumber: buildNumber,
            preReleaseVersion: preReleaseVersion
        )

        let buildLocalizationId = try ReadBuildLocalizationOperation(
            options: .init(id: buildId, locale: locale)
        )
        .execute(with: requestor)
        .await()
        .id

        try DeleteBuildLocalizationOperation(
            options: .init(localizationId: buildLocalizationId)
        )
        .execute(with: requestor)
        .await()
    }

    func createBuildLocalization(
        bundleId: String,
        buildNumber: String,
        preReleaseVersion: String,
        locale: String,
        whatsNew: String
    ) async throws -> BuildLocalization {
        let buildId = try await buildIdFrom(
            bundleId: bundleId,
            buildNumber: buildNumber,
            preReleaseVersion: preReleaseVersion
        )

        return BuildLocalization(
            try CreateBuildLocalizationOperation(
                options: .init(buildId: buildId, locale: locale, whatsNew: whatsNew)
            )
            .execute(with: requestor)
            .await()
        )
    }

    func upateBuildLocalization(
        bundleId: String,
        buildNumber: String,
        preReleaseVersion: String,
        locale: String,
        whatsNew: String
    ) async throws -> BuildLocalization {
        let buildId = try await buildIdFrom(
            bundleId: bundleId,
            buildNumber: buildNumber,
            preReleaseVersion: preReleaseVersion
        )

        let buildLocalizationId = try ReadBuildLocalizationOperation(
            options: .init(id: buildId, locale: locale)
        )
        .execute(with: requestor)
        .await()
        .id

        return BuildLocalization(
            try UpdateBuildLocalizationOperation(
                options: .init(
                    localizationId: buildLocalizationId,
                    whatsNew: whatsNew
                )
            )
            .execute(with: requestor)
            .await()
        )
    }

    func getTestFlightProgram(bundleIds: [String] = []) async throws -> TestFlightProgram {
        let appsOperation = ListAppsOperation(options: .init(bundleIds: bundleIds))
        let apps = try await appsOperation.execute(with: service)
        let appIds = apps.map(\.id)

        // Passing appIds can cause undefined API behaviour for list beta testers so we retrieve all
        // testers with a large limit to ensure a small number of requests
        let betaTestersOperation = ListBetaTestersOperation(options: .init(limit: 200))
        let betaGroupsOperation = ListBetaGroupsOperation(options: .init(appIds: appIds))

        let (testers, groups) = try betaTestersOperation.execute(with: requestor)
            .zip(betaGroupsOperation.execute(with: requestor))
            .await()

        let betagroups = groups.map(Model.BetaGroup.init)

        // Using beta groups from API to update beta groups in testers, for adding extra informations like app info in a group
        let betatesters = testers.map(Model.BetaTester.init).map { tester -> Model.BetaTester in
            var updatedTester = tester

            updatedTester.betaGroups = tester.betaGroups.map { betagroupInTester in
                if let betagroup = betagroups.first(where: { $0.id == betagroupInTester.id }) {
                    return betagroup
                }

                return betagroupInTester
            }

            return updatedTester
        }

        return TestFlightProgram(
            apps: apps.map(Model.App.init),
            testers: betatesters,
            groups: betagroups
        )
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

    func buildIdAndGroupIdsFrom(
        bundleId: String,
        version: String,
        buildNumber: String,
        groupNames: [String]
    ) async throws -> (buildId: String, groupIds: [String]) {
        let appId = try await ReadAppOperation(options: .init(identifier: .bundleId(bundleId)))
            .execute(with: service)
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
        let groupIds = try ListBetaGroupsOperation(options: .init(appIds: [], names: [], sort: nil))
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

    private func buildIdFrom(
        bundleId: String,
        buildNumber: String,
        preReleaseVersion: String
    ) async throws -> String {
        let appId = try await ReadAppOperation(options: .init(identifier: .bundleId(bundleId)))
        .execute(with: service)
        .id

        return try ReadBuildOperation(
            options: .init(
                appId: appId,
                buildNumber: buildNumber,
                preReleaseVersion: preReleaseVersion
            )
        )
        .execute(with: requestor)
        .await()
        .build
        .id
    }

}
