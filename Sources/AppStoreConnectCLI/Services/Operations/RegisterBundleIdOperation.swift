// Copyright 2022 Itty Bitty Apps Pty Ltd

import Bagbutik
import Foundation
import Model

struct RegisterBundleIdOperation: APIOperationV2 {
    typealias Output = Bagbutik.BundleId
    
    struct Options {
        let bundleId: String
        let name: String
        let platform: BundleIdPlatform
    }

    private let service: BagbutikService
    private let options: Options

    init(service: BagbutikService, options: Options) {
        self.service = service
        self.options = options
    }

    func execute() async throws -> Output {
        let attributes = BundleIdCreateRequest.Data.Attributes(
            identifier: options.bundleId,
            name: options.name,
            platform: options.platform
        )
        let request = BundleIdCreateRequest(data: .init(attributes: attributes))
        
        return try await service.request(
            .createBundleIdV1(requestBody: request)
        ).data
    }
    
}
