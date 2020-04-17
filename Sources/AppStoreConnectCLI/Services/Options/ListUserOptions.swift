// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK

struct ListUsersOptions {
    let limitVisibleApps: Int?
    let limitUsers: Int?
    let sort: ListUsers.Sort?
    let filterUsername: [String]
    let filterRole: [UserRole]
    let filterVisibleApps: [String]
    let includeVisibleApps: Bool
}
