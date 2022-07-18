// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import Foundation
import Model

struct ReadBundleIdOperation: APIOperationV2 {
    typealias Output = Bagbutik.BundleId
    
    struct Options {
        let bundleId: String
    }

    enum Error: LocalizedError {
        case couldNotFindBundleId(String)
        case bundleIdNotUnique(String)

        var errorDescription: String? {
            switch self {
            case .couldNotFindBundleId(let bundleId):
                return "Couldn't find Bundle ID: '\(bundleId)'."
            case .bundleIdNotUnique(let bundleId):
                return "The Bundle ID you provided '\(bundleId)' is not unique."
            }
        }
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with service: BagbutikService) async throws -> Output {
        let bundleIds = try await service.request(
            .listBundleIdsV1(filters: [.identifier([options.bundleId])])
        )
            .data
            .filter { $0.attributes?.identifier == self.options.bundleId }
        
        switch bundleIds.count {
        case 0:
            throw Error.couldNotFindBundleId(self.options.bundleId)
        case 1:
            return bundleIds.first!
        default:
            throw Error.bundleIdNotUnique(self.options.bundleId)
        }
    }
    
}
