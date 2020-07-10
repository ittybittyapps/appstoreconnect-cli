// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import CodableCSV
import SwiftyTextTable
import Yams

protocol Reader {
    associatedtype Output

    func read(filePath: String) -> Output
}

public enum Readers {

    public struct FileReader<T: Decodable>: Reader {

        let format: InputFormat

        public init(format: InputFormat) {
            self.format = format
        }

        public func read(filePath: String) -> T {
            switch format {
            case .json:
                return readJSON(from: filePath)
            case .yaml:
                return readYAML(from: filePath)
            case .csv:
                return readCSV(from: filePath)
            }
        }

        public func readJSON<T: Decodable>(from filePath: String) -> T {
            guard
                let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8),
                let data = fileContents.data(using: .utf8),
                let result = try? JSONDecoder().decode(T.self, from: data) else {
                    fatalError("Could not read JSON file: \(filePath)")
            }

            return result
        }

        public func readYAML<T: Decodable>(from filePath: String) -> T {
            guard
                let fileContents = try? String(contentsOfFile: filePath, encoding: .utf8),
                let result = try? YAMLDecoder().decode(T.self, from: fileContents) else {
                    fatalError("Could not read YAML file: \(filePath)")
            }

            return result
        }

        public func readCSV<T: Decodable>(from filePath: String) -> T {
            let decoder = CSVDecoder {
                $0.encoding = .utf8
                $0.headerStrategy = .firstLine
            }

            guard
                let result = try? decoder.decode(T.self, from: URL(fileURLWithPath: "\(filePath)")) else {
                    fatalError("Could not read CSV file: \(filePath)")
            }

            return result
        }
    }

}
