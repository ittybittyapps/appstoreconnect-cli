// Copyright 2022 Itty Bitty Apps Pty Ltd

import Bagbutik
import Foundation
import Model

extension ListUserInvitationsV1.Filter.Roles {
    init(_ role: Model.UserRole) {
        switch role {
        case .admin:
            self = .admin
        case .finance:
            self = .finance
        case .accountHolder:
            self = .accountHolder
        case .sales:
            self = .sales
        case .marketing:
            self = .marketing
        case .appManager:
            self = .appManager
        case .developer:
            self = .developer
        case .accessToReports:
            self = .accessToReports
        case .customerSupport:
            self = .customerSupport
        case .imageManager:
            self = .imageManager
        case .createApps:
            self = .createApps
        case .cloudManagedDeveloperId:
            self = .cloudManagedDeveloperId
        case .cloudManagedAppDistribution:
            self = .cloudManagedAppDistribution
        }
    }
}
