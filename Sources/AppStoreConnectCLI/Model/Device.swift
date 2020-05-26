// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import Model
import SwiftyTextTable

// MARK: - API conveniences

extension Model.Device {
    init( _ attributes: AppStoreConnect_Swift_SDK.Device.Attributes) {
        self.init(
            udid: attributes.udid,
            addedDate: attributes.addedDate,
            name: attributes.name,
            deviceClass: attributes.deviceClass?.rawValue,
            model: attributes.model,
            platform: attributes.platform?.rawValue,
            status: attributes.status?.rawValue
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

extension Model.Device: ResultRenderable, TableInfoProvider {
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
          deviceClass,
          model,
          platform,
          status,
        ].map { $0 ?? "" }
    }
}
