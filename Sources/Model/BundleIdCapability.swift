// Copyright 2022 Itty Bitty Apps Pty Ltd

import Foundation

public struct BundleIdCapability: Codable, Equatable {
    public let capabilityType: String?

    // TODO: support Capability Settings
    
    public init(capabilityType: String?) {
        self.capabilityType = capabilityType

    }
}
