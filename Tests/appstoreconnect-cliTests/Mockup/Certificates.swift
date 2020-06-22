// Copyright 2020 Itty Bitty Apps Pty Ltd

@testable import AppStoreConnectCLI
import AppStoreConnect_Swift_SDK
import Foundation

// swiftlint:disable force_try
extension Certificate {
    static let readCertificateResponse: CertificatesResponse = try! jsonDecoder.decodeFixture(named: "v1/certificates/read_certificate_success")

    static let noCertificateResponse: CertificatesResponse = try! jsonDecoder.decodeFixture(named: "v1/certificates/no_certificate")

    static let notUniqueResponse: CertificatesResponse = try! jsonDecoder.decodeFixture(named: "v1/certificates/not_unique")
}
