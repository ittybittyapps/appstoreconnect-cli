// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct App: Codable, Equatable {
    public let id: String?
    public var bundleId: String?
    public var name: String?
    public var primaryLocale: String?
    public var sku: String?

    public init(
        id: String?,
        bundleId: String?,
        name: String?,
        primaryLocale: String?,
        sku: String?
    ) {
        self.id = id
        self.bundleId = bundleId
        self.name = name
        self.primaryLocale = primaryLocale
        self.sku = sku
    }
}
