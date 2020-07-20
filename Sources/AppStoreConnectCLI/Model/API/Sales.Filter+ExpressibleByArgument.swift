// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

private typealias Filter = DownloadSalesAndTrendsReports.Filter

extension Filter.Frequency: ExpressibleByArgument, CustomStringConvertible {
    private typealias AllCases = [Filter.Frequency]

    private static var allCases: AllCases {
        [.DAILY, .MONTHLY, .WEEKLY, .YEARLY]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
}

extension Filter.ReportType: ExpressibleByArgument, CustomStringConvertible {
    private typealias AllCases = [Filter.ReportType]

    private static var allCases: AllCases {
        [.SALES, .PRE_ORDER, .NEWSSTAND, .SUBSCRIPTION, .SUBSCRIPTION_EVENT, .SUBSCRIBER]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
}

extension Filter.ReportSubType: ExpressibleByArgument, CustomStringConvertible {
    private typealias AllCases = [Filter.ReportSubType]

    private static var allCases: AllCases {
        [.SUMMARY, .DETAILED, .OPT_IN]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
}
