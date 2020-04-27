// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation

struct ListCertificatesOptions {
    let filterSerial: String?
    let sort: Certificates.Sort?
    let filterType: CertificateType?
    let filterDisplayName: String?
    let limit: Int?
}

struct ReadCertificateOptions {
    let serial: String
}
