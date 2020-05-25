// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import CodableCSV
import Combine
import SwiftyTextTable
import Yams
import AppStoreConnect_Swift_SDK

protocol Reader {
    associatedtype Output

    func read(filePath: String) -> Output
}

enum Readers {

    struct FileReader<T: Decodable>: Reader {
        let format: InputFormat

        func read(filePath: String) -> T {
            switch format {
            case .json:
                return readJSON(from: filePath)
            case .yaml:
                return readYAML(from: filePath)
            case .csv:
                return readCSV(from: filePath)
            }
        }

        private func readJSON<T: Decodable>(from filePath: String) -> T {
            guard
                let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8),
                let data = fileContents.data(using: .utf8),
                let result = try? JSONDecoder().decode(T.self, from: data) else {
                    fatalError("Could not read JSON file: \(filePath)")
            }

            return result
        }

        private func readYAML<T: Decodable>(from filePath: String) -> T {
            guard
                let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8),
                let result = try? YAMLDecoder().decode(T.self, from: fileContents) else {
                    fatalError("Could not read YAML file: \(filePath)")
            }

            return result
        }

        private func readCSV<T: Decodable>(from filePath: String) -> T {
            let decoder = CSVDecoder {
                $0.encoding = .utf8
                $0.headerStrategy = .firstLine
            }

            guard
                let url = URL(string: "file://\(filePath)"),
                let result = try? decoder.decode(T.self, from: url) else {
                    fatalError("Could not read CSV file: \(filePath)")
            }

            return result
        }
    }

}
