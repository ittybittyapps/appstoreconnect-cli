// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Foundation

public typealias Filter = DownloadSalesAndTrendsReports.Filter

extension Filter.Frequency: ExpressibleByArgument, CustomStringConvertible {
    public typealias AllCases = [Filter.Frequency]

    public static var allCases: AllCases {
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
    public typealias AllCases = [Filter.ReportType]

    public static var allCases: AllCases {
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
    public typealias AllCases = [Filter.ReportSubType]

    public static var allCases: AllCases {
        [.SUMMARY, .DETAILED, .OPT_IN]
    }

    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
}
