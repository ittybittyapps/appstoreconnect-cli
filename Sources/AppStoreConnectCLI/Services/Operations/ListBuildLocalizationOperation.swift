// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListBuildLocalizationOperation: APIOperation {

    struct Options {
        let id: String
        let limit: Int?
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<[BetaBuildLocalization], Error> {
        guard options.limit != nil else {
            return requestor.requestAllPages { [options] in
                .betaBuildLocalizations(
                    ofBuildWithId: options.id,
                    fields: [],
                    next: $0
                )
            }
            .map { $0.flatMap(\.data) }
            .eraseToAnyPublisher()
        }

        return requestor.request(
            .betaBuildLocalizations(
                ofBuildWithId: options.id,
                fields: [],
                limit: options.limit)
            )
            .map(\.data)
            .eraseToAnyPublisher()
    }

}

extension BetaBuildLocalizationsResponse: PaginatedResponse { }

