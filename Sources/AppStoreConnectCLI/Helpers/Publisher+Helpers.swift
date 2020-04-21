// Copyright 2020 Itty Bitty Apps Pty Ltd

import Combine
import Foundation

extension Publisher {
    func awaitResult() -> Result<[Output], Failure> {
        var result: Result<[Output], Failure> = .success([])

        let dispatchQueue = DispatchQueue.global(qos: .userInteractive)
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        _ = self
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

        dispatchGroup.wait()

        return result
    }
}
extension Publisher where Output: ResultRenderable, Failure == Error {
    func renderResult(format: OutputFormat) -> AnyCancellable {
        self.sink(
            receiveCompletion: Renderers.CompletionRenderer().render,
            receiveValue: Renderers.ResultRenderer<Output>(format: format).render
        )
    }
}

extension Publisher where Output == Void, Failure == Error {
    func renderResult(format: OutputFormat) -> AnyCancellable {
        self.sink(
            receiveCompletion: Renderers.CompletionRenderer().render,
            receiveValue: Renderers.null
        )
    }
}
