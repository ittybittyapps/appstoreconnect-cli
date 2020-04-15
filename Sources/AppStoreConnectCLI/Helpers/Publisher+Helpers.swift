// Copyright 2020 Itty Bitty Apps Pty Ltd

import Combine
import Foundation

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
