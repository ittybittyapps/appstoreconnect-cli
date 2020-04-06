// Copyright 2020 Itty Bitty Apps Pty Ltd

import ArgumentParser
import Foundation

let envPrefix = "@env:"

protocol EnvironmentLoadableArgument: ExpressibleByArgument, CustomStringConvertible {
    var argument: String { get }
    var value: String { get }
}

extension EnvironmentLoadableArgument {

    static func environment(_ variableName: String) -> Self {
        Self(argument: "\(envPrefix)\(variableName)")!
    }

    var description: String { argument }

    var value: String {
       guard argument.hasPrefix(envPrefix) else {
           return argument
       }

       let envKey = String(argument.dropFirst(envPrefix.count))
       return ProcessInfo.processInfo.environment[envKey] ?? ""
   }
}
