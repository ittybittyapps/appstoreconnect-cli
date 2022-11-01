// Copyright 2022 Itty Bitty Apps Pty Ltd

import Bagbutik
import Foundation
import Model
import SwiftyTextTable

extension Model.BundleIdCapability {
   
    init(_ attributes: Bagbutik.BundleIdCapability.Attributes?) {
        self.init(capabilityType: attributes?.capabilityType?.rawValue)
    }
    
    init(_ apiBundleId: Bagbutik.BundleIdCapability) {
        self.init(apiBundleId.attributes)
    }
}

extension Model.BundleIdCapability: ResultRenderable, TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
        return [
            TextTableColumn(header: "Capability Type"),
        ]
    }
    
    var tableRow: [CustomStringConvertible] {
        return [
            capabilityType ?? "",
        ]
    }
}
