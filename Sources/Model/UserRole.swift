// Copyright 2022 Itty Bitty Apps Pty Ltd

import Foundation
import ArgumentParser

/// Represents a user's role.
public enum UserRole: String, CaseIterable, Codable, Equatable {
    /// Serves as a secondary contact for teams and has many of the same responsibilities as the Account Holder role. Admins have access to all apps.
    case admin = "ADMIN"
    /// Manages financial information, including reports and tax forms. A user assigned this role can view all apps in Payments and Financial Reports, Sales and Trends, and App Analytics.
    case finance = "FINANCE"
    /// Responsible for entering into legal agreements with Apple. The person who completes program enrollment is assigned the Account Holder role in both the Apple Developer account and App Store Connect.
    case accountHolder = "ACCOUNT_HOLDER"
    /// Analyzes sales, downloads, and other analytics for the app.
    case sales = "SALES"
    /// Manages marketing materials and promotional artwork. A user assigned this role will be contacted by Apple if the app is in consideration to be featured on the App Store.
    case marketing = "MARKETING"
    /// Manages all aspects of an app, such as pricing, App Store information, and app development and delivery.
    case appManager = "APP_MANAGER"
    /// Manages development and delivery of an app.
    case developer = "DEVELOPER"
    /// Downloads reports associated with a role. The Access To Reports role is an additional permission for users with the App Manager, Developer, Marketing, or Sales role. If this permission is added, the user has access to all of your apps.
    case accessToReports = "ACCESS_TO_REPORTS"
    /// Analyzes and responds to customer reviews on the App Store. If a user has only the Customer Support role, they'll go straight to the Ratings and Reviews section when they click on an app in My Apps.
    case customerSupport = "CUSTOMER_SUPPORT"
    case imageManager = "IMAGE_MANAGER"
    case createApps = "CREATE_APPS"
    case cloudManagedDeveloperId = "CLOUD_MANAGED_DEVELOPER_ID"
    case cloudManagedAppDistribution = "CLOUD_MANAGED_APP_DISTRIBUTION"
}
