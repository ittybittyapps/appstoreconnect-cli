// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct ReadBuildLocalizationOperation: APIOperation {

    struct Options {
        let id: String
        let locale: String
    }

    enum Error: LocalizedError {
        case notUnique
        case notFound

        var errorDescription: String? {
            switch self {
            case .notUnique:
                return "Localization info is not unique."
            case .notFound:
                return "Unable to find Localization info for build."
            }
        }
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) -> AnyPublisher<BetaBuildLocalization, Swift.Error> {
        requestor.requestAllPages { [options] in
            .betaBuildLocalizations(
                ofBuildWithId: options.id,
                fields: nil,
                next: $0
            )
        }
        .map {
            $0.flatMap {
                $0.data.filter {
                    $0.attributes?.locale?.lowercased() == self.options.locale.lowercased()
                }
            }
        }
        .tryMap { response -> BetaBuildLocalization in
            switch response.first {
            case .some(let localizationInfo) where response.count == 1:
                return localizationInfo
            case .some:
                throw Error.notUnique
            case .none:
                throw Error.notFound
            }
        }
        .eraseToAnyPublisher()
    }

}
