// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK

extension Certificate {
    static let createCertificateResponse: CertificateResponse = jsonDecoder.decodeFixture(named: "v1/certificates/created_success")

    static let readCertificateResponse: CertificatesResponse = jsonDecoder.decodeFixture(named: "v1/certificates/read_certificate_success")

    static let noCertificateResponse: CertificatesResponse = jsonDecoder.decodeFixture(named: "v1/certificates/no_certificate")

    static let notUniqueResponse: CertificatesResponse = jsonDecoder.decodeFixture(named: "v1/certificates/not_unique")
}
