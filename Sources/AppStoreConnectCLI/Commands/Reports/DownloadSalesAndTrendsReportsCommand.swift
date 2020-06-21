// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import FileSystem

struct DownloadSalesAndTrendsReportsCommand: CommonParsableCommand {

    enum ReportFilter: String, ExpressibleByArgument, CaseIterable, CustomStringConvertible {

        // SALES
        case salesDailySummary = "sales_daily_summary"
        case salesWeeklySummary = "sales_weekly_summary"
        case salesMonthlySummary = "sales_monthly_summary"
        case salesYearlySummary = "sales_yearly_summary"
        case salesWeeklyOptIn = "sales_weekly_opt_in"

        // SUBSCRIPTION
        case subscriptionDailySummary = "subscription_daily_summary"
        case subscriptionEventDailySummary = "subscription_event_daily_summary"

        // SUBSCRIBER
        case subscriberDailyDetailed = "subscriber_daily_detailed"

        // NEWSSTAND
        case newsstandDailyDetailed = "newsstand_daily_detailed"
        case newsstandWeeklyDetailed = "newsstand_weekly_detailed"

        // PRE_ORDER
        case preOrderDailySummary = "pre_order_daily_summary"
        case preOrderWeeklySummary = "pre_order_weekly_summary"
        case preOrderMonthlySummary = "pre_order_monthly_summary"
        case preOrderYearlySummary = "pre_order_yearly_summary"

        var description: String {
            rawValue
        }

        typealias Filter = DownloadSalesAndTrendsReports.Filter

        struct RequestParams {
            let type: Filter.ReportType
            let subType: Filter.ReportSubType
            let frequency: Filter.Frequency
            let version: Version
        }

        // swiftlint:disable identifier_name
        enum Version: String {
            case _1_0 = "1_0"
            case _1_2 = "1_2"
        }

        var params: RequestParams {
            switch self {
            case .salesDailySummary:
                return .init(type: .SALES, subType: .SUMMARY, frequency: .DAILY, version: ._1_0)
            case .salesWeeklySummary:
                return .init(type: .SALES, subType: .SUMMARY, frequency: .WEEKLY, version: ._1_0)
            case .salesMonthlySummary:
                return .init(type: .SALES, subType: .SUMMARY, frequency: .MONTHLY, version: ._1_0)
            case .salesYearlySummary:
                return .init(type: .SALES, subType: .SUMMARY, frequency: .YEARLY, version: ._1_0)
            case .salesWeeklyOptIn:
                return .init(type: .SALES, subType: .OPT_IN, frequency: .WEEKLY, version: ._1_0)
            case .subscriptionDailySummary:
                return .init(type: .SUBSCRIPTION, subType: .SUMMARY, frequency: .DAILY, version: ._1_2)
            case .subscriptionEventDailySummary:
                return .init(type: .SUBSCRIPTION_EVENT, subType: .SUMMARY, frequency: .DAILY, version: ._1_2)
            case .subscriberDailyDetailed:
                return .init(type: .SUBSCRIBER, subType: .DETAILED, frequency: .DAILY, version: ._1_2)
            case .newsstandDailyDetailed:
                return .init(type: .NEWSSTAND, subType: .DETAILED, frequency: .DAILY, version: ._1_0)
            case .newsstandWeeklyDetailed:
                return .init(type: .NEWSSTAND, subType: .DETAILED, frequency: .WEEKLY, version: ._1_0)
            case .preOrderDailySummary:
                return .init(type: .PRE_ORDER, subType: .SUMMARY, frequency: .DAILY, version: ._1_0)
            case .preOrderWeeklySummary:
                return .init(type: .PRE_ORDER, subType: .SUMMARY, frequency: .WEEKLY, version: ._1_0)
            case .preOrderMonthlySummary:
                return .init(type: .PRE_ORDER, subType: .SUMMARY, frequency: .MONTHLY, version: ._1_0)
            case .preOrderYearlySummary:
                return .init(type: .PRE_ORDER, subType: .SUMMARY, frequency: .YEARLY, version: ._1_0)
            }
        }
    }

    static var configuration = CommandConfiguration(
        commandName: "sales",
        abstract: "Download sales and trends reports filtered by your specified criteria.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(
        help: ArgumentHelp(
            "Sales and trends report filters.",
            discussion: "Possibable values: \(ReportFilter.allCases)"
        )
    )
    var filter: ReportFilter

    @Argument(help:
        ArgumentHelp(
            "The report date to download.",
            discussion: "The date is specified in the YYYY-MM-DD format for all report frequencies except DAILY, which does not require a specified date."
        )
    )
    var reportDate: String

    @Argument(help: "Your vendor number.")
    var vendorNumber: String

    @Argument(help: "The downloaded report file name.")
    var outputFilename: String

    func run() throws {
        let service = try makeService()

        let requestFilters = filter.params

        let result = try service.downloadSales(
            frequency: [requestFilters.frequency],
            reportType: [requestFilters.type],
            reportSubType: [requestFilters.subType],
            vendorNumber: [vendorNumber],
            reportDate: [reportDate],
            version: [requestFilters.version.rawValue]
        )

        try ReportProcessor(path: outputFilename).write(result)
    }
}
