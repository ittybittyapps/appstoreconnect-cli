// Copyright 2020 Itty Bitty Apps Pty Ltd

import Foundation

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

    func compare() -> [SyncStrategy<T>] {
        serverResourcesSet
            .subtracting(localResourcesSet)
            .compactMap { resource -> SyncStrategy<T>? in
                localResources
                    .contains(where: { resource.compareIdentity == $0.compareIdentity })
                    ? nil
                    : .delete(resource)
            }
        +
        localResourcesSet
            .subtracting(serverResourcesSet)
            .compactMap { resource -> SyncStrategy<T>? in
                serverResourcesSet
                    .contains(
                        where: { resource.compareIdentity == $0.compareIdentity }
                    )
                    ? .update(resource)
                    : .create(resource)
        }
    }
}
