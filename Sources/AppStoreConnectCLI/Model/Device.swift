// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import AppStoreConnect_Swift_SDK
import SwiftyTextTable

struct Device: Codable {
    var id: String
    var addedDate: Date?
    var name: String?
    // Returns nil for valid results probably because the attribute
    // property is misnamed. Issue has been raised in the repository
    var deviceClass: DeviceClass?
    var model: String?
    var udid: String?
    var platform: BundleIdPlatform?
    var status: DeviceStatus?
}

// TODO: Extract these extensions somewhere that makes sense down the road

// MARK: - API conveniences

extension Device {
    static func fromAPIDevice(_ apiDevice: AppStoreConnect_Swift_SDK.Device) -> Device {
        let attributes = apiDevice.attributes
        return Device(id: apiDevice.id,
                      addedDate: attributes.addedDate,
                      name: attributes.name,
                      deviceClass: attributes.devicesClass,
                      model: attributes.model,
                      udid: attributes.udid,
                      platform: attributes.platform,
                      status: attributes.status)
    }
}

// MARK: - TextTable conveniences

extension Device {
    static func tableColumns() -> [TextTableColumn] {
        return [
            TextTableColumn(header: "ID"),
            TextTableColumn(header: "Date Added"),
            TextTableColumn(header: "Name"),
            TextTableColumn(header: "Device Class"),
            TextTableColumn(header: "Model"),
            TextTableColumn(header: "UDID"),
            TextTableColumn(header: "Platform"),
            TextTableColumn(header: "Status"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return [
            id,
            addedDate != nil
                ? formatter.string(from: addedDate!)
                : "N/A",
            name ?? "N/A",
            deviceClass?.rawValue ?? "N/A",
            model ?? "N/A",
            udid ?? "N/A",
            platform?.rawValue ?? "N/A",
            status?.rawValue ?? "N/A"
        ]
    }
}

extension Device: ResultRenderable {
    func renderAsTable() -> String {
        var table = TextTable(columns: Self.tableColumns())
        table.addRow(values: self.tableRow)
        return table.render()
    }
}

extension Array: ResultRenderable where Element == Device {
    func renderAsTable() -> String {
        var table = TextTable(columns: Element.tableColumns())
        table.addRows(values: self.map(\.tableRow))
        return table.render()
    }
}
