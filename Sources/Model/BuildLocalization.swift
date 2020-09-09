// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct BuildLocalization: Codable, Equatable {
    public let locale: String?
    public let whatsNew: String?

    public init(
        locale: String?,
        whatsNew: String?
    ) {
        self.locale = locale
        self.whatsNew = whatsNew
    }
}
