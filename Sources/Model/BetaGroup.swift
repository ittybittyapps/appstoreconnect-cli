// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct BetaGroup: Codable, Equatable {

    public let id: String
    public let app: App?
    public let groupName: String?
    public let isInternal: Bool?
    public let publicLink: String?
    public let publicLinkEnabled: Bool?
    public let publicLinkLimit: Int?
    public let publicLinkLimitEnabled: Bool?
    public let creationDate: String?

    public init(
        id: String,
        app: App?,
        groupName: String?,
        isInternal: Bool?,
        publicLink: String?,
        publicLinkEnabled: Bool?,
        publicLinkLimit: Int?,
        publicLinkLimitEnabled: Bool?,
        creationDate: String?
    ) {
        self.id = id
        self.app = app
        self.groupName = groupName
        self.isInternal = isInternal
        self.publicLink = publicLink
        self.publicLinkEnabled = publicLinkEnabled
        self.publicLinkLimit = publicLinkLimit
        self.publicLinkLimitEnabled = publicLinkLimitEnabled
        self.creationDate = creationDate
    }

}
