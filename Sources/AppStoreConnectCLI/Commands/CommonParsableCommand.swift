// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Foundation

protocol CommonParsableCommand: ParsableCommand {
    var common: CommonOptions { get }

    func makeClient() throws -> HTTPClient
}

extension CommonParsableCommand {
    func makeClient() throws -> HTTPClient {
        HTTPClient(configuration: try APIConfiguration(common.authOptions))
    }
}

struct AuthOptions: ParsableArguments {

    enum Error: Swift.Error {
        case issuerNotProvided
        case apiKeyIdNotProvided
    }

    @Option(
        default: .environment("APPSTORE_CONNECT_ISSUER_ID"),
        help: ArgumentHelp(
            "An AppStore Connect API Key issuer ID.",
            discussion:
                """
                This value can be obtained from the AppStore Connect portal and takes the form of a UUID.

                If not specified on the command line this value will be read from the environment variable APPSTORE_CONNECT_ISSUER_ID.
                """,
            valueName: "uuid"
        )
    )
    var apiIssuer: IssuerID

    @Option(
        default: .environment("APPSTORE_CONNECT_API_KEY_ID"),
        help: ArgumentHelp(
            "An AppStoreConnect API Key ID.",
            discussion:
                """
                This value can be obtained from the AppStore Connect portal and takes the form of an 10 alpha-numeric identifier, eg. 7MM5YSX5LS

                This option will search the environment for a key with the name of \(APIKeyID.apiKeyEnvironmentKey). The contents of this environment key are expected to be a PKCS 8 (.p8) formatted private key associated with this Key ID.

                If environment variable is empty, in the incorrect format, or not found then this option will search following  directories in sequence for a private key file with the name of 'AuthKey_<keyid>.p8': \(ListFormatter.localizedString(byJoining: APIKeyID.searchPaths)).

                If not specified on the command line the value of this option will be read from the environment variable APPSTORE_CONNECT_API_KEY_ID.
                """,
            valueName: "keyid"
        )
    )
    var apiKeyId: APIKeyID
}

protocol EnvironmentLoadableArgument: ExpressibleByArgument, CustomStringConvertible {
    static var envPrefix: String { get }
    var argument: String { get }
    var value: String { get }
}

extension EnvironmentLoadableArgument {
    static var envPrefix: String { "@env:" }

    static func environment(_ variableName: String) -> Self {
        Self(argument: "\(envPrefix)\(variableName)")!
    }

    var description: String { argument }

    var value: String {
       guard argument.hasPrefix(Self.envPrefix) else {
           return argument
       }

       let envKey = String(argument.dropFirst(Self.envPrefix.count))
       return ProcessInfo.processInfo.environment[envKey] ?? ""
   }
}

struct IssuerID: EnvironmentLoadableArgument {
    let argument: String

    init?(argument: String) {
        self.argument = argument
    }
}

struct APIKeyID: EnvironmentLoadableArgument {

    enum Error: Swift.Error {
        case apiKeyNotFound
    }

    static let apiKeyEnvironmentKey = "APPSTORE_CONNECT_API_KEY"
    static let searchPaths = ["./private_keys", "~/private_keys", "~/.private_keys", "~/.appstoreconnect/private_keys"]

    var argument: String

    init?(argument: String) {
        self.argument = argument
    }

    private func findKeyFileURL() -> URL? {
        let fileManager = FileManager()
        let authKeyFilename = "AuthKey_\(value).p8"

        return Self.searchPaths
            .lazy
            .map { $0.replacingOccurrences(of: "~", with: fileManager.homeDirectoryForCurrentUser.path) }
            .map(URL.init(fileURLWithPath:))
            .map { $0.appendingPathComponent(authKeyFilename) }
            .first { fileManager.fileExists(atPath: $0.path) }
    }

    func load() throws -> String {

        // TODO: validate the format of the env var content
        // TODO: validate format of file is correct (if found)

        guard let apiKeyFileContent =
            try (ProcessInfo.processInfo.environment["APPSTORE_CONNECT_API_KEY"] ??
                findKeyFileURL().map { try String(contentsOf: $0, encoding: .utf8) })
        else {
            throw Error.apiKeyNotFound
        }


        return apiKeyFileContent
            .components(separatedBy: .newlines)
            .filter { $0.hasSuffix("PRIVATE KEY-----") == false }
            .joined()
    }
}

struct CommonOptions: ParsableArguments {
    @OptionGroup()
    var authOptions: AuthOptions

    @Flag(default: .table, help: "Display results in specified format.")
    var outputFormat: OutputFormat
}
