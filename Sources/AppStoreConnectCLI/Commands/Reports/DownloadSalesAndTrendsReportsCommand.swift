// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import FileSystem

struct DownloadSalesAndTrendsReportsCommand: CommonParsableCommand {

    typealias Filter = DownloadSalesAndTrendsReports.Filter

    static var configuration = CommandConfiguration(
        commandName: "sales",
        abstract: "Download sales and trends reports filtered by your specified criteria.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "Frequency of the report to download. (\(Filter.Frequency.allCases.description))")
    var frequency: Filter.Frequency

    @Argument(help:
        ArgumentHelp(
            "The report date to download.",
            discussion: "The date is specified in the YYYY-MM-DD format for all report frequencies except DAILY, which does not require a specified date."
        )
    ) var reportDate: String

    @Argument(help: "The report to download.  (\(Filter.ReportType.allCases.description))")
    var reportType: Filter.ReportType

    @Argument(help: "The report sub type to download.  (\(Filter.ReportSubType.allCases.description))")
    var reportSubType: Filter.ReportSubType

    @Argument(help: "Your vendor number.")
    var vendorNumber: String

    @Argument(help: "The downloaded report file name.")
    var outputFilename: String

    @Option(help: "The version of the report.")
    var version: [String]

    func run() throws {
        let service = try makeService()

        let result = try service.downloadSales(
            frequency: [frequency],
            reportType: [reportType],
            reportSubType: [reportSubType],
            vendorNumber: [vendorNumber],
            reportDate: [reportDate],
            version: version
        )

        try ReportProcessor(path: outputFilename).write(result)
    }
}
