// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

public struct BetaGroup: Codable, Equatable, Hashable {

    public typealias EmailAddress = String

    public let id: String?
    public let groupName: String
    public let isInternal: Bool?
    public let publicLink: String?
    public let publicLinkEnabled: Bool?
    public let publicLinkLimit: Int?
    public let publicLinkLimitEnabled: Bool?
    public let creationDate: String?
    public let testers: [EmailAddress]

    public init(
        id: String?,
        groupName: String,
        isInternal: Bool?,
        publicLink: String?,
        publicLinkEnabled: Bool?,
        publicLinkLimit: Int?,
        publicLinkLimitEnabled: Bool?,
        creationDate: String?,
        testers: [String] = []
    ) {
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
