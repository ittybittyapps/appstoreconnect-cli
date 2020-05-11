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

enum PageInput {
    case prev, next, exit

    init(_ input: String?) {
        switch input?.lowercased() {
        case "prev":
            self = .prev
        case "next":
            self = .next
        default:
            self = .exit
        }
    }
}

enum PageLinks {
    case hasNext(URL)
    case hasPrev(URL)
    case hasBoth(URL, URL)
    case none

    init(_ links: PagedDocumentLinks) {
        switch (links.first, links.next){
        case let (.some(first), .some(next)):
            self = .hasBoth(first, next)
        case let (.some(first), _):
            self = .hasPrev(first)
        case let (_, .some(next)):
            self = .hasNext(next)
        case (_, _):
            self = .none
        }
    }
}

extension CommonParsableCommand {

    typealias PageFetcher<T: ResultRenderable> = (_ url: URL) throws -> (T, PagedDocumentLinks)

    func pagingSupport<T: ResultRenderable> (links: PagedDocumentLinks, fetcher: @escaping PageFetcher<T>) throws {
        let renderHelperText = { (name: String) in
            print("The result contains more than one page, please input \(name) to jump to \(name) page, press any key to exit")
        }

        let fetch = { (url: URL) in
            let result = try fetcher(url)

            result.0.render(format: self.common.outputFormat)

            try self.pagingSupport(links: result.1, fetcher: fetcher)
        }

        switch PageLinks(links) {
        case .hasNext(let url):
            renderHelperText("'next'")
            switch PageInput(readLine()) {
            case .next:
                try fetch(url)
            default:
               break
        }

        case .hasPrev(let url):
            renderHelperText("'prev'")
            switch PageInput(readLine()) {
            case .prev:
                try fetch(url)
            default:
                break
        }

        case .hasBoth(let preUrl, let nextUrl):
            renderHelperText("'prev' / 'next'")
            switch PageInput(readLine()) {
            case .prev:
                try fetch(preUrl)
            case .next:
                try fetch(nextUrl)
            default:
                break
        }

        case .none:
            break
        }
    }
}
