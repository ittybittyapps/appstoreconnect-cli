// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

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
        let sdkBetaTester = try InviteTesterOperation(options: options).execute(with: requestor).await()

        let getBetaTesterOptions = GetBetaTesterOperation.Options(id: sdkBetaTester.id, email: nil)

        let output = try GetBetaTesterOperation(options: getBetaTesterOptions)
            .execute(with: requestor)
            .await()

        return BetaTester(output)
    }

    func getBetaTester(
        email: String,
        limitApps: Int?,
        limitBuilds: Int?,
        limitBetaGroups: Int?
    ) throws -> BetaTester {
        let operation = GetBetaTesterOperation(
            options: .init(
                email: email,
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
            try GetBetaTesterOperation(options: .init(id: nil, email: $0)).execute(with: requestor)
        }

        let ids = try Publishers.ConcatenateMany(requests).awaitMany().map(\.betaTester.id)

        return try DeleteBetaTestersOperation(options: .init(ids: ids))
            .execute(with: requestor)
            .awaitMany()
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

    func listBetaGroups(bundleIds: [String]) throws -> [BetaGroup] {
        let operation = GetAppsOperation(options: .init(bundleIds: bundleIds))
        let appIds = try operation.execute(with: requestor).await().map(\.id)

        return try listBetaGroups(appIds: appIds)
    }

    func listBetaGroups(appIds: [String]) throws -> [BetaGroup] {
        let operation = ListBetaGroupsOperation(options: .init(appIds: appIds))

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

        let modifyBetaGroupOperation = ModifyBetaGroupOperation(
            options: .init(
                app: app,
                currentGroupName: currentGroupName,
                newGroupName: newGroupName,
                publicLinkEnabled: publicLinkEnabled,
                publicLinkLimit: publicLinkLimit,
                publicLinkLimitEnabled: publicLinkLimitEnabled
            )
        )

        let betaGroup = try modifyBetaGroupOperation.execute(with: requestor).await()

        return BetaGroup(app, betaGroup)
    }

    func readBuild(bundleId: String, buildNumber: [String], preReleaseVersion: [String]) throws -> [BuildDetailsInfo] {
      let appsOperation = GetAppsOperation(options: .init(bundleIds: [bundleId]))
      let appId = try appsOperation.execute(with: requestor).await().map(\.id)

      let readBuildOperation = ReadBuildOperation(options: .init(appId: appId, buildNumber: buildNumber, preReleaseVersion: preReleaseVersion))

      return try readBuildOperation.execute(with: requestor).await()
    }

    func expireBuild(bundleId: String, buildNumber: String, preReleaseVersion: String, expired: Bool) throws -> Void {
      let appsOperation = GetAppsOperation(options: .init(bundleIds: [bundleId]))
      let appId = try appsOperation.execute(with: requestor).await().map(\.id)

      let readBuildOperation = ReadBuildOperation(options: .init(appId: appId, buildNumber: [buildNumber], preReleaseVersion: [preReleaseVersion]))
      let buildId = try readBuildOperation.execute(with: requestor).await().map(\.id).first

      let expireBuildOperation = ExpireBuildOperation(options: .init(buildId: buildId, expired: expired))
      _ = try expireBuildOperation.execute(with: requestor).await()
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
