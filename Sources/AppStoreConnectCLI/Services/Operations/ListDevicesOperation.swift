// Copyright 2020 Itty Bitty Apps Pty Ltd

import AppStoreConnect_Swift_SDK
import Combine

struct ListDevicesOperation: APIOperation {

    struct Options {
       let filterName: [String]
       let filterPlatform: [Platform]
       let filterUDID: [String]
       let filterStatus: DeviceStatus?
       let sort: Devices.Sort?
       let limit: Int?
    }

    private let options: Options

    init(options: Options) {
        self.options = options
    }

    func execute(with requestor: EndpointRequestor) throws -> AnyPublisher<[Device], Error> {

        var filters = [Devices.Filter]()

        filters += options.filterName.isEmpty ? [] : [.name(options.filterName)]

        filters += options.filterPlatform.isEmpty ? [] : [.platform(options.filterPlatform)]

        filters += options.filterUDID.isEmpty ? [] : [.udid(options.filterUDID)]

        filters += options.filterStatus != nil ? [.status([options.filterStatus!])] : []

        let sort = [options.sort].compactMap { $0 }

        guard let limit = options.limit else {
            return requestor.requestAllPages {
                    .listDevices(
                        filter: filters,
                        sort: sort,
                        next: $0
                    )
                }
                .map { $0.flatMap { $0.data } }
                .eraseToAnyPublisher()
        }

        return requestor.request(
                .listDevices(
                    filter: filters,
                    sort: sort,
                    limit: limit
                )
            )
            .map(\.data)
            .eraseToAnyPublisher()
    }
}

extension DevicesResponse: PaginatedResponse { }
