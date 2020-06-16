// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import FileSystem

struct DownloadFinancialReportsCommand: CommonParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "financial",
        abstract: "Download finance reports filtered by your specified criteria.")

    @OptionGroup()
    var common: CommonOptions

    @Argument(help:
        ArgumentHelp(
            "You can download consolidated or separate financial reports per territory.",
            discussion: "Possible values: (\(DownloadFinanceReports.RegionCode.allCases.map { $0.rawValue }.joined(separator: ", ")))"
        )
    ) var regionCode: DownloadFinanceReports.RegionCode

    @Argument(help:
        ArgumentHelp(
            "The date of the report you wish to download based on the Apple Fiscal Calendar.",
            discussion: "The date is specified in the YYYY-MM format."
        )
    ) var reportDate: String

    @Argument(help: "Your vendor number.")
    var vendorNumber: String

    @Argument(help: "The downloaded report file name.")
    var outputFilename: String

    func run() throws {
        let service = try makeService()

        let result = try service.downloadFinanceReports(
            regionCode: regionCode,
            reportDate: reportDate,
            vendorNumber: vendorNumber
        )

        try ReportProcessor(path: outputFilename).write(result)
    }
}
