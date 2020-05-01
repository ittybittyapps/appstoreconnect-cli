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

    func createCertificate(with options: CreateCertificateOptions) -> AnyPublisher<Certificate, Error> {
        CreateCertificateOperation(options: options).execute(with: requestor)
    }

    func inviteBetaTesterToGroups(with options: InviteBetaTesterOptions) throws -> AnyPublisher<BetaTester, Error> {
        try InviteTesterOperation(options: options).execute(with: requestor)
    }

    func getBetaTesterInfo(
        email: String,
        limitApps: Int?,
        limitBuilds: Int?,
        limitBetaGroups: Int?
    ) throws -> BetaTester {
        let response = try GetBetaTestersInfoOperation(options:
            .init(email: email,
                  limitApps: limitApps,
                  limitBuilds: limitBuilds,
                  limitBetaGroups: limitBetaGroups)
            )
            .execute(with: requestor)
            .await()

        return response.data.map { BetaTester($0, response.included) }.first!
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
