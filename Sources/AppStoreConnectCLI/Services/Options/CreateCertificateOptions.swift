// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Foundation

struct CreateCertificateOptions {
    let certificateType: CertificateType
    let csrContent: String
}
