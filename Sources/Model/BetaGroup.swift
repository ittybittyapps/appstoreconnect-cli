// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct BetaGroup: Codable, Equatable {
    public let app: App
    public let id: String?
    public let groupName: String
    public let isInternal: Bool?
    public let publicLink: String?
    public let publicLinkEnabled: Bool?
    public let publicLinkLimit: Int?
    public let publicLinkLimitEnabled: Bool?
    public let creationDate: String?
    public var testers: String? // tester csv file path

    public init(
        app: App,
        id: String?,
        groupName: String,
        isInternal: Bool?,
        publicLink: String?,
        publicLinkEnabled: Bool?,
        publicLinkLimit: Int?,
        publicLinkLimitEnabled: Bool?,
        creationDate: String?,
        testers: String? = nil
    ) {
        self.app = app
        self.id = id
        self.groupName = groupName
        self.isInternal = isInternal
        self.publicLink = publicLink
        self.publicLinkEnabled = publicLinkEnabled
        self.publicLinkLimit = publicLinkLimit
        self.publicLinkLimitEnabled = publicLinkLimitEnabled
        self.creationDate = creationDate
        self.testers = testers
    }
}

extension BetaGroup: Hashable {
    public static func == (lhs: BetaGroup, rhs: BetaGroup) -> Bool {
        return lhs.id == rhs.id &&
            lhs.groupName == rhs.groupName &&
            lhs.publicLinkEnabled == rhs.publicLinkEnabled &&
            lhs.publicLinkLimit == rhs.publicLinkLimit &&
            lhs.publicLinkLimitEnabled == rhs.publicLinkLimitEnabled
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(groupName)
        hasher.combine(publicLinkEnabled)
        hasher.combine(publicLinkLimit)
        hasher.combine(publicLinkLimitEnabled)
    }
}
