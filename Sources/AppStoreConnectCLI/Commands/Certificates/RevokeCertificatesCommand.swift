// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

struct RevokeCertificatesCommand: CommonParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "revoke",
        abstract: "Revoke lost, stolen, compromised, or expiring signing certificates."
    )

    @OptionGroup()
    var common: CommonOptions

    @Argument(help: "The certificates' serial numbers. (eg. 1A23BCDEF4G5D6C7)")
    var serials: [String]

    func validate() throws {
        if serials.isEmpty {
            throw ValidationError("Invalid input, you must provide at least one certificate serial number")
        }
    }

    func run() throws {
        let service = try makeService()
        _ = try service.revokeCertificates(serials: serials)

        if common.quiet == false {
            serials.forEach {
                print("🚮 Certificate `\($0)` revoked.")
            }
        }
    }

}
