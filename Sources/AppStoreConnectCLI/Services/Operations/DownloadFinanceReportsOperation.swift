// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct DownloadFinanceReportsOperation: APIOperation {

    struct Options {
        let regionCode: [DownloadFinanceReports.RegionCode]
        let reportDate: String
        let vendorNumber: String
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Data, Error> {
        requestor.request(
                .downloadFinanceReports(
                    regionCodes: options.regionCode,
                    reportDate: options.reportDate,
                    vendorNumber: options.vendorNumber
                )
            )
            .eraseToAnyPublisher()
    }
}
