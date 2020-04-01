// Copyright 2020 Itty Bitty Apps Pty Ltd

import Combine

extension Publishers {

    /// A publisher created by applying the concatenate function to many upstream publishers.
    ///
    /// Emits all of one publisher's elements before those from the next publisher.
    public struct ConcatenateMany<Upstream>: Publisher where Upstream: Publisher {

        /// The kind of values published by this publisher.
        public typealias Output = Upstream.Output

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Upstream.Failure

        public let publishers: [Upstream]

        private let concatenatePublisher: AnyPublisher<Upstream.Output, Upstream.Failure>

        public init(_ upstream: Upstream...) {
            self.init(upstream)
        }

        public init<S>(_ upstream: S) where Upstream == S.Element, S : Swift.Sequence {
            publishers = Array(upstream)
            let partialResult = Empty<Upstream.Output, Upstream.Failure>().eraseToAnyPublisher()
            concatenatePublisher = publishers
                .reduce(partialResult) { Concatenate(prefix: $0, suffix: $1).eraseToAnyPublisher() }
        }

        public func receive<S>(subscriber: S)
            where
            S: Subscriber,
            ConcatenateMany.Failure == S.Failure,
            ConcatenateMany.Output == S.Input
        {
            concatenatePublisher.receive(subscriber: subscriber)
        }

    }

}
