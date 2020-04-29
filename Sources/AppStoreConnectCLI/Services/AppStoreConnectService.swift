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

    func createBetaGroup(
        appBundleId: String,
        groupName: String,
        publicLinkEnabled: Bool,
        publicLinkLimit: Int?
    ) throws -> BetaGroup {
        let getAppsOptions = GetAppsOperation.Options(bundleIds: [appBundleId])
        let getAppsOperation = GetAppsOperation(options: getAppsOptions)
        // We use a force unwrap here as the operation handles errors raised by not finding our app
        let app = try getAppsOperation.execute(with: requestor).await().first!

        let createBetaGroupOptions = CreateBetaGroupOperation.Options(
            app: app,
            groupName: groupName,
            publicLinkEnabled: publicLinkEnabled,
            publicLinkLimit: publicLinkLimit
        )

        let createBetaGroupOperation = CreateBetaGroupOperation(options: createBetaGroupOptions)

        return try createBetaGroupOperation
            .execute(with: requestor)
            .map(BetaGroup.init)
            .await()
    }

    func listBetaGroups(appIds: [String], bundleIds: [String]) throws -> [BetaGroup] {
        var appIds = appIds

        // Fill out appIds if no appIds are specified but bundleIds are
        if appIds.isEmpty && !bundleIds.isEmpty {
            let getAppsOptions = GetAppsOperation.Options(bundleIds: bundleIds)
            let getAppsOperation = GetAppsOperation(options: getAppsOptions)
            appIds = try getAppsOperation.execute(with: requestor).await().map(\.id)
        }

        let listBetaGroupsOptions = ListBetaGroupsOperation.Options(appIds: appIds)
        let listBetaGroupsOperation = ListBetaGroupsOperation(options: listBetaGroupsOptions)

        return try listBetaGroupsOperation
            .execute(with: requestor)
            .map { $0.map(BetaGroup.init) }
            .await()
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
