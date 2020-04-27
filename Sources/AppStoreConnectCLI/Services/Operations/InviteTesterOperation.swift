// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct InviteTesterOperation: APIOperation {

    struct InviteBetaTesterDependencies {
        let betaTesterResponse: (APIEndpoint<BetaTesterResponse>) -> Future<BetaTesterResponse, Error>
    }

    private let options: InviteBetaTesterOptions

    init(options: InviteBetaTesterOptions) {
        self.options = options
    }

    func execute(with dependencies: InviteBetaTesterDependencies) -> AnyPublisher<BetaTester, Error> {

        let requests = options.betaGroupIds.map { (id: String) -> AnyPublisher<BetaTesterResponse, Error> in
            let endpoint = APIEndpoint.create(
                betaTesterWithEmail: options.email,
                firstName: options.firstName,
                lastName: options.lastName,
                betaGroupIds: [id]
            )

            return dependencies
                .betaTesterResponse(endpoint)
                .eraseToAnyPublisher()
        }

        let testerId = try! Publishers.ConcatenateMany(requests)
            .last()
            .await()
            .data
            .id

        return GetBetaTesterInfoOperation(
                options: GetBetaTesterInfoOptions(id: testerId)
            )
            .execute(
                with: .init(betaTesterResponse: dependencies.betaTesterResponse)
            )
            .eraseToAnyPublisher()
    }

}
