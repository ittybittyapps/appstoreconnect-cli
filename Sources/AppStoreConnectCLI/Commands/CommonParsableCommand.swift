// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

protocol CommonParsableCommand: ParsableCommand {
    var common: CommonOptions { get }

    func makeService() throws -> AppStoreConnectService
}

extension CommonParsableCommand {
    func makeService() throws -> AppStoreConnectService {
        AppStoreConnectService(configuration: try APIConfiguration(common.authOptions))
    }
}

struct CommonOptions: ParsableArguments {
    @OptionGroup()
    var authOptions: AuthOptions

    @Flag(default: .table, help: "Display results in specified format.")
    var outputFormat: OutputFormat
}

extension CommonParsableCommand {

    typealias PageFetcher<T: ResultRenderable> = (_ url: URL) throws -> (T, PagedDocumentLinks)

    func pagingSupport<T: ResultRenderable> (links: PagedDocumentLinks, fetcher: @escaping PageFetcher<T>) throws {

        let fetch = { (url: URL) in
            let result = try fetcher(url)

            result.0.render(format: self.common.outputFormat)

            try self.pagingSupport(links: result.1, fetcher: fetcher)
        }

        if let next = links.next {
            print("The result contains more than one page, would you like to load next page? y/n.")

            if readLine() == "y" {
                try fetch(next)
            }
        }
    }
}
