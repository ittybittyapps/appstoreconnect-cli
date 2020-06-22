// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct ReportsCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "reports",
        abstract: "Download your sales and financial reports.",
        subcommands: [
             DownloadSalesAndTrendsReportsCommand.self,
             DownloadFinancialReportsCommand.self,
        ]
    )
}
