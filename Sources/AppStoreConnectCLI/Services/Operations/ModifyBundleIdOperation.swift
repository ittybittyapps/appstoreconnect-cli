// Copyright 2020 Itty Bitty Apps Pty Ltd

import Bagbutik
import Combine
import Foundation

struct ModifyBundleIdOperation: APIOperationV2 {

    typealias Output = Bagbutik.BundleId
    
    struct Options {
        let resourceId: String
        let name: String
    }

    private let service: BagbutikService
    private let options: Options
    
    init(service: BagbutikService, options: Options) {
        self.service = service
        self.options = options
    }

    func execute() async throws -> Output {
        try await service.request(
            .updateBundleIdV1(
                id: options.resourceId,
                requestBody: BundleIdUpdateRequest(
                    data: .init(
                        id: options.resourceId,
                        attributes: .init(name: options.name)
                    )
                )
            )
        )
        .data
    }
}
