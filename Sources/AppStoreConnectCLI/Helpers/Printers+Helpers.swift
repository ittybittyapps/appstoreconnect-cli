// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation
import Combine

enum Printers {
    static func handleError(_ completion: Subscribers.Completion<Error>) {
        switch completion {
            case .finished: print("Operation completed successfully")
            case .failure(let error): print(String(describing: error))
        }
    }
}
