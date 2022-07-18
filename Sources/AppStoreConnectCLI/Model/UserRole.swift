// Copyright 2022 Itty Bitty Apps Pty Ltd

import ArgumentParser
import AppStoreConnect_Swift_SDK
import Bagbutik
import Foundation
import Model

extension Model.UserRole: ExpressibleByArgument, CustomStringConvertible {
 
    public init?(argument: String) {
        self.init(rawValue: argument.uppercased())
    }

    public var description: String {
        rawValue.lowercased()
    }
    
}

extension Model.UserRole {
    init(_ apiUserRole: Bagbutik.UserRole) {
        switch apiUserRole {
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

extension Bagbutik.UserRole {
    init(_ userRole: Model.UserRole) {
        switch userRole {
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

extension AppStoreConnect_Swift_SDK.UserRole {
    init(_ userRole: Model.UserRole) {
        switch userRole {
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
        case .cloudManagedAppDistribution:
            self = .cloudManagedAppDistribution
        default:
            fatalError("Unsupported case \(userRole))!")
        }
    }
}
