// Copyright 2020 Itty Bitty Apps Pty Ltd

import Combine
import Foundation

enum PublisherAwaitError: LocalizedError {
    case timedOut(timeout: DispatchTime)
    case expectedOutput
    case expectedSingleOutput(outputCount: Int)

    var errorDescription: String? {
        switch self {
        case .timedOut(let timeout):
            return "Expected publisher output but timed out with timeout: \(timeout)"
        case .expectedOutput:
            return "Expected publisher output but none received"
        case .expectedSingleOutput(let outputCount):
            return "Expected single publisher output but received \(outputCount)"
        }
    }
}

extension Publisher {
    func await(timeout: DispatchTime = .now() + 30) throws -> Output {
        let allOutput = try awaitMany()

        guard let output = allOutput.first, allOutput.count == 1 else {
            throw PublisherAwaitError.expectedSingleOutput(outputCount: allOutput.count)
        }

        return output
    }

    func awaitMany(timeout: DispatchTime = .now() + 30) throws -> [Output] {
        var result: Result<[Output], Failure>?

        let dispatchQueue = DispatchQueue.global(qos: .userInteractive)
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        let cancellable = self
            .subscribe(on: dispatchQueue)
            .collect()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        result = .failure(failure)
                    }

                    dispatchGroup.leave()
                },
                receiveValue: {
                    result = .success($0)
                }
            )

        let timeoutResult = dispatchGroup.wait(timeout: timeout)
        cancellable.cancel()

        switch (result, timeoutResult) {
        case (_, .timedOut):
            throw PublisherAwaitError.timedOut(timeout: timeout)
        case (.none, .success):
            throw PublisherAwaitError.expectedOutput
        case (.some(.success(let output)), .success):
            return output
        case (.some(.failure(let error)), .success):
            throw error
        }
    }
}
