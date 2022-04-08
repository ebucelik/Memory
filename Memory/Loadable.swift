//
//  Loadable.swift
//  Memory
//
//  Created by Ing. Ebu Celik on 28.03.22.
//

import Foundation

public struct APIError: Error {}

public enum Loadable<T: Equatable>: Equatable {
    case none
    case loading
    case loaded(T)
    case refreshing(T)
    case error(APIError)

    public static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true

        case (.loading, .loading):
            return true

        case let (.loaded(lhsObject), .loaded(rhsObject)):
            return lhsObject == rhsObject

        case let (.refreshing(lhsObject), .refreshing(rhsObject)):
            return lhsObject == rhsObject

        case let (.error(lhsObject), .error(rhsObject)):
            return lhsObject.localizedDescription == rhsObject.localizedDescription

        default:
            return false
        }
    }
}
