// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine
import Foundation

struct DownloadSalesOperation: APIOperation {

    typealias Filter = DownloadSalesAndTrendsReports.Filter

    struct Options {
       let frequency: [Filter.Frequency]
       let reportType: [Filter.ReportType]
       let reportSubType: [Filter.ReportSubType]
       let vendorNumber: [String]
       let reportDate: [String]
       let version: [String]
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<Data, Error> {
        var filter: [Filter] = [
            .frequency(options.frequency),
            .reportDate(options.reportDate),
            .reportSubType(options.reportSubType),
            .vendorNumber(options.vendorNumber),
        ]

        if options.reportDate.isNotEmpty { filter.append(.reportType(options.reportType)) }
        if options.version.isNotEmpty { filter.append(.version(options.version)) }

        return requestor
            .request(.downloadSalesAndTrendsReports(filter: filter))
            .eraseToAnyPublisher()
    }
}
