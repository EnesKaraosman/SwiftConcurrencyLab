//
//  StateView.swift
//
//
//  Created by Enes Karaosman on 19.12.2024.
//

import SwiftUI

enum UIState<T> {
    typealias Item = T
    case initial
    case loading
    case success(Item)
    case error(String)
}

extension UIState: Equatable where Self.Item: Equatable {
    static func == (lhs: UIState<T>, rhs: UIState<T>) -> Bool {
        if case let .success(lhsItem) = lhs, case let .success(rhsItem) = rhs {
            return lhsItem == rhsItem
        } else if case .error(let lhsItem) = lhs, case .error(let rhsItem) = rhs {
            return lhsItem == rhsItem
        } else if case .loading = lhs, case .loading = rhs {
            return true
        }

        return false
    }
}

struct StateView<T, Content: View>: View {
    @Binding var state: UIState<T>

    var onSuccess: ((T) -> Content)?

    var body: some View {
        switch state {
        case .initial:
            EmptyView()
        case .loading:
            ProgressView().id(UUID())
        case .success(let t):
            onSuccess?(t)
        case .error(let error):
            Text(error).foregroundColor(.red)
        }
    }
}

extension String: Error {}

func debugDate() -> String {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "H:mm:ss.SSSS"

    return formatter.string(from: date) + " => " // -> "17:51:15.1720"
}
