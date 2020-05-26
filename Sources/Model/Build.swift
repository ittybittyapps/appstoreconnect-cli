// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct Build: Codable, Equatable {
    public let app: App?
    public let platform: String?
    public let version: String?
    public let externalBuildState: String?
    public let internalBuildState: String?
    public let autoNotifyEnabled: String?
    public let buildNumber: String?
    public let processingState: String?
    public let minOsVersion: String?
    public let uploadedDate: String?
    public let expirationDate: String?
    public let expired: String?
    public let usesNonExemptEncryption: String?
    public let betaReviewState: String?

    public init(
        app: App?,
        platform: String?,
        version: String?,
        externalBuildState: String?,
        internalBuildState: String?,
        autoNotifyEnabled: String?,
        buildNumber: String?,
        processingState: String?,
        minOsVersion: String?,
        uploadedDate: String?,
        expirationDate: String?,
        expired: String?,
        usesNonExemptEncryption: String?,
        betaReviewState: String?
    ) {
        self.app = app
        self.platform = platform
        self.version = version
        self.externalBuildState = externalBuildState
        self.internalBuildState = internalBuildState
        self.autoNotifyEnabled = autoNotifyEnabled
        self.buildNumber = buildNumber
        self.processingState = processingState
        self.minOsVersion = minOsVersion
        self.uploadedDate = uploadedDate
        self.expirationDate = expirationDate
        self.expired = expired
        self.usesNonExemptEncryption = usesNonExemptEncryption
        self.betaReviewState = betaReviewState
    }
}
