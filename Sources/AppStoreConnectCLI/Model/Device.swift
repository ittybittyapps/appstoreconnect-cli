// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import SwiftyTextTable

struct Device: Renderable {
    var udid: String?
    var addedDate: Date?
    var name: String?
    var deviceClass: DeviceClass?
    var model: String?
    var platform: BundleIdPlatform?
    var status: DeviceStatus?
}

// TODO: Extract these extensions somewhere that makes sense down the road

// MARK: - API conveniences

extension Device {
    init( _ attributes: AppStoreConnect_Swift_SDK.Device.Attributes) {
        self.init(
            udid: attributes.udid,
            addedDate: attributes.addedDate,
            name: attributes.name,
            deviceClass: attributes.deviceClass,
            model: attributes.model,
            platform: attributes.platform,
            status: attributes.status
        )
    }

    init(_ apiDevice: AppStoreConnect_Swift_SDK.Device) {
        self.init(apiDevice.attributes)
    }

    init(_ response: AppStoreConnect_Swift_SDK.DeviceResponse) {
        self.init(response.data)
    }
}

// MARK: - TextTable conveniences

extension Device: TableInfoProvider {
    static func tableColumns() -> [TextTableColumn] {
        return [
            TextTableColumn(header: "UDID"),
            TextTableColumn(header: "Name"),
            TextTableColumn(header: "Date Added"),
            TextTableColumn(header: "Device Class"),
            TextTableColumn(header: "Model"),
            TextTableColumn(header: "Platform"),
            TextTableColumn(header: "Status"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        return [
          udid,
          name,
          addedDate?.formattedDate,
          deviceClass?.rawValue,
          model,
          platform?.rawValue,
          status?.rawValue
        ].map { $0 ?? "" }
    }
}
