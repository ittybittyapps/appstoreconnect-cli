// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import ArgumentParser
import Combine
import Foundation
import SwiftyTextTable
import Yams

struct ReadDeviceInfoCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "read",
        abstract: "Get information for a specific device registered to your team"
    )

    @Option(default: "config/auth.yml", help: "The APIConfiguration.")
    var auth: String

    @Argument(help: "The ID of the device to find")
    var deviceId: String

    @Option(help: "Return exportable results in provided format (\(OutputFormat.allCases.map { $0.rawValue }.joined(separator: ", "))).")
    var outputFormat: OutputFormat?

    func run() throws {
        let api = try HTTPClient(authenticationYmlPath: auth)

        let request = APIEndpoint.readDeviceInformation(id: deviceId)

        _ = api.request(request)
            .map { Device.fromAPIDevice($0.data) }
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(String(describing: error))
                }
            }, receiveValue: { [self] device in
                self.output(device)
            })

    }

    //TODO: this is temporary until such a time that we have the Renderers sorted
    func output(_ device: Device) {
        do {
            switch outputFormat ?? .table {
                case .json:
                    let jsonEncoder = JSONEncoder()
                    jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                    let json = try jsonEncoder.encode(device)
                    print(String(data: json, encoding: .utf8)!)
                case .yaml:
                    let yamlEncoder = YAMLEncoder()
                    let yaml = try yamlEncoder.encode(device)
                    print(yaml)
                case .table:
                    let columns = Device.tableColumns()
                    var table = TextTable(columns: columns)
                    table.addRow(values: device.tableRow)
                    print(table.render())
            }
        } catch {
            print(error)
        }
    }
}
