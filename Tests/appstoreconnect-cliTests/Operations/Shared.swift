// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

let jsonDecoder: JSONDecoder = {
    let jsonDecoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)

    return jsonDecoder
}()

enum TestError: Error, Equatable {
    case somethingBadHappened
}

extension JSONDecoder {
    func decodeFixture<T: Decodable>(named: String) throws -> T {
        let fixture = try Fixture(named: named)
        return try decode(T.self, from: fixture.data)
    }
}
