// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Model
import SwiftyTextTable

extension Model.BuildLocalization {
    init(_ localization: AppStoreConnect_Swift_SDK.BetaBuildLocalization) {
        self.init(
            locale: localization.attributes?.locale,
            whatsNew: localization.attributes?.whatsNew
        )
    }
}

extension Model.BuildLocalization: ResultRenderable, TableInfoProvider {

    static func tableColumns() -> [TextTableColumn] {
        [
            TextTableColumn(header: "Locale"),
            TextTableColumn(header: "What's New (truncated)"),
        ]
    }

    var tableRow: [CustomStringConvertible] {
        [
            locale ?? "",
            (whatsNew ?? "")
                .debugDescription
                .replacingOccurrences(of: "\\n", with: " ")
                .truncate(to: 100),
        ]
    }

}
