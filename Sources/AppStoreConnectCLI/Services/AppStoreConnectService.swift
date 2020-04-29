// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

class AppStoreConnectService {
    private let provider: APIProvider

    init(configuration: APIConfiguration) {
        provider = APIProvider(configuration: configuration)
    }

    func listUsers(with options: ListUsersOptions) -> AnyPublisher<[User], Error> {
        let dependencies = ListUsersOperation.Dependencies(users: request)
        let operation = ListUsersOperation(options: options)

        return operation.execute(with: dependencies)
    }

    func getUserInfo(with options: GetUserInfoOptions) -> AnyPublisher<User, Error> {
        let dependencies = GetUserInfoOperation.Dependencies(usersResponse: request)
        let operation = GetUserInfoOperation(options: options)

        return operation.execute(with: dependencies)
    }

    func listCertificates(with options: ListCertificatesOptions) -> AnyPublisher<[Certificate], Error> {
        let dependencies = ListCertificatesOperation.Dependencies(certificatesResponse: request)
        let operation = ListCertificatesOperation(options: options)

        return operation.execute(with: dependencies)
    }

    func createCertificate(with options: CreateCertificateOptions) -> AnyPublisher<Certificate, Error> {
        let dependencies = CreateCertificateOperation.Dependencies(certificateResponse: request)
        let operation = CreateCertificateOperation(options: options)

        return operation.execute(with: dependencies)
    }

    func inviteBetaTesterToGroups(with options: InviteBetaTesterOptions) throws -> AnyPublisher<BetaTester, Error> {
        let dependencies = InviteTesterOperation.Dependencies(
            appsResponse: request,
            betaGroupsResponse: request,
            betaTesterResponse: request
        )

        let operation = InviteTesterOperation(options: options)

        return try operation.execute(with: dependencies)
    }

    func createBetaGroup(with options: CreateBetaGroupOptions) -> AnyPublisher<BetaGroup, Error> {
        let dependencies = CreateBetaGroupOperation.Dependencies(
            apps: request,
            createBetaGroup: request)
        let operation = CreateBetaGroupOperation(options: options)

        return operation.execute(with: dependencies)
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
