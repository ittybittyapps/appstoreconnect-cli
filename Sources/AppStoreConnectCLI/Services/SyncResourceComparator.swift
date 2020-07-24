// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

enum SyncAction<T: SyncResultRenderable>: Equatable {
    case delete(T)
    case create(T)
    case update(T)
}

protocol SyncResourceProcessable: SyncResourceComparable, SyncResultRenderable { }

protocol SyncResourceComparable: Hashable {
    associatedtype T: Comparable

    var compareIdentity: T { get }
}

struct SyncResourceComparator<T: SyncResourceProcessable> {

    let localResources: [T]
    let serverResources: [T]

    private var localResourcesSet: Set<T> { Set(localResources) }
    private var serverResourcesSet: Set<T> { Set(serverResources) }

    func compare() -> [SyncAction<T>] {
        serverResourcesSet
            .subtracting(localResourcesSet)
            .compactMap { resource -> SyncAction<T>? in
                localResources
                    .contains(where: { resource.compareIdentity == $0.compareIdentity })
                    ? nil
                    : .delete(resource)
            }
        +
        localResourcesSet
            .subtracting(serverResourcesSet)
            .compactMap { resource -> SyncAction<T>? in
                serverResourcesSet
                    .contains(
                        where: { resource.compareIdentity == $0.compareIdentity }
                    )
                    ? .update(resource)
                    : .create(resource)
        }
    }
}
