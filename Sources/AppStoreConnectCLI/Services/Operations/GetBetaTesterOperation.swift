// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct GetBetaTesterOperation: APIOperation {

    struct Options {
        enum TesterIdentifier {
            case id(String)
            case email(String)
        }

        let identifier: TesterIdentifier
        var limitApps: Int?
        var limitBuilds: Int?
        var limitBetaGroups: Int?
    }

    private enum Error: LocalizedError {
        case betaTesterNotFound(String)
        case betaTesterNotUnique(String)

        var errorDescription: String? {
            switch self {
            case .betaTesterNotFound(let email):
                return "Beta tester with provided email '\(email)' doesn't exist."
            case .betaTesterNotUnique(let email):
                return "Beta tester with email address '\(email)' not unique"
            }
        }
    }

    struct Output {
        let betaTester: AppStoreConnect_Swift_SDK.BetaTester
        let betaGroups: [AppStoreConnect_Swift_SDK.BetaGroup]?
        let apps: [AppStoreConnect_Swift_SDK.App]?

        init(betaTester: AppStoreConnect_Swift_SDK.BetaTester, includes: [BetaTesterRelationship]?) {
            self.betaTester = betaTester
            self.betaGroups = includes?.compactMap { relationship -> AppStoreConnect_Swift_SDK.BetaGroup? in
                if case let .betaGroup(betaGroup) = relationship {
                    return betaGroup
                }
                return nil
            }

            self.apps = includes?.compactMap { relationship -> AppStoreConnect_Swift_SDK.App? in
                if case let .app(app) = relationship {
                    return app
                }
                return nil
            }
        }
    }

    let options: Options

    var listTesterslimits: [ListBetaTesters.Limit] {
        var limits: [ListBetaTesters.Limit] = []

        if let limitApps = options.limitApps {
            limits.append(.apps(limitApps))
        }

        if let limitBuilds = options.limitBuilds {
            limits.append(.builds(limitBuilds))
        }

        if let limitBetaGroups = options.limitBetaGroups {
            limits.append(.betaGroups(limitBetaGroups))
        }

        return limits
    }

    var getTesterlimits: [GetBetaTester.Limit] {
        var limits: [GetBetaTester.Limit] = []

        if let limitApps = options.limitApps {
            limits.append(.apps(limitApps))
        }

        if let limitBuilds = options.limitBuilds {
            limits.append(.builds(limitBuilds))
        }

        if let limitBetaGroups = options.limitBetaGroups {
            limits.append(.betaGroups(limitBetaGroups))
        }

        return limits
    }

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Output, Swift.Error> {
        switch options.identifier {
        case .id(let id):
            let endpoint = APIEndpoint.betaTester(
                withId: id,
                include: [.betaGroups, .apps],
                limit: getTesterlimits
            )

            return requestor.request(endpoint)
                .tryMap { (response: BetaTesterResponse) -> Output in
                    return Output(
                        betaTester: response.data,
                        includes: response.included
                    )
            }
            .eraseToAnyPublisher()

        case .email(let email):
            let endpoint = APIEndpoint.betaTesters(
                filter: [.email([email])],
                include: [.betaGroups, .apps],
                limit: listTesterslimits
            )

            return requestor.request(endpoint)
                .tryMap { (response: BetaTestersResponse) -> Output in
                    switch response.data.count {
                    case 0:
                        throw Error.betaTesterNotFound(email)
                    case 1:
                        return Output(
                            betaTester: response.data.first!,
                            includes: response.included
                        )
                    default:
                        throw Error.betaTesterNotUnique(email)
                    }
            }
            .eraseToAnyPublisher()
        }
    }

}
