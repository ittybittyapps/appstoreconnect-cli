// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import Foundation

struct ReadAppOperation: APIOperationV2 {
    typealias Output = App
    
    struct Options {
        let identifier: AppLookupIdentifier
    }

    enum Error: LocalizedError {
        case notFound(String)
        case notUnique(String)

        var errorDescription: String? {
            switch self {
            case .notFound(let identifier):
                return "App with provided identifier '\(identifier)' doesn't exist."
            case .notUnique(let identifier):
                return "App with provided identifier '\(identifier)' not unique."
            }
        }
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with service: BagbutikService) async throws -> Output {
        let result: App
        
        switch options.identifier {
        case .appId(let appId):
            result = try await service.request(.getAppV1(id: appId)).data
                
        case .bundleId(let bundleId):
            let data = try await service.requestAllPages(.listAppsV1(filters: [.bundleId([bundleId])])).data
                          
            switch data.count {
            case 0:
                throw Error.notFound(bundleId)
            case 1:
                result = data.first!
            default:
                throw Error.notUnique(bundleId)
            }
        }

        return result
    }

}
