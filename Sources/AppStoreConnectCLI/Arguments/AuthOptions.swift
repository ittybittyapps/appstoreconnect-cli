// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

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
                This value can be obtained from the AppStore Connect portal and takes the form of an 10 character alpha-numeric identifier, eg. 7MM5YSX5LS

                This option will search the environment for a key with the name of \(APIKeyID.apiKeyEnvironmentKey). The contents of this environment key are expected to be a PKCS 8 (.p8) formatted private key associated with this Key ID.

                If environment variable is empty, in the incorrect format, or not found then this option will search following  directories in sequence for a private key file with the name of 'AuthKey_<keyid>.p8': \(ListFormatter.localizedString(byJoining: APIKeyID.searchPaths)).

                If not specified on the command line the value of this option will be read from the environment variable APPSTORE_CONNECT_API_KEY_ID.
                """,
            valueName: "keyid"
        )
    )
    var apiKeyId: APIKeyID
}
