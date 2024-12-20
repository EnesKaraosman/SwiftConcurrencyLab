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
        } else if case .error = lhs, case .error = rhs {
            return lhs == rhs
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


actor Logger {
    // Internal storage for log messages
    private var logs: [String] = []

    // AsyncStream continuation to publish messages
    private var continuation: AsyncStream<String>.Continuation?

    // Lazy initialization for the AsyncStream to avoid capturing `self` prematurely
    lazy var logStream: AsyncStream<String> = .init { continuation in
        self.continuation = continuation
    }

    // Method to log a message
    func log(_ message: String) {
        let debugMessage = debugDate() + message
        logs.append(debugMessage)
        continuation?.yield(debugMessage)
        print(debugMessage)
    }

    // Retrieve all logged messages
    func getAllLogs() -> [String] {
        return logs
    }

    func clear() {
        logs.removeAll()
    }

    // End the stream when no more updates will occur
    func finishLogging() {
        continuation?.finish()
    }
}

struct LoggerView: View {
    let logger: Logger

    @State
    private var messages: [String] = []

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Logs;")
                    .fontWeight(.bold)
                Spacer()
                Button("Clear") {
                    Task {
                        messages.removeAll()
                        await logger.clear()
                    }
                }
            }
            ForEach(messages, id: \.self) { message in
                Text(message)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .font(.footnote)
        .task {
            for await log in await logger.logStream {
                messages.append(log)
            }
        }
        .padding()
        .background(Color.init(.systemGroupedBackground))
        .cornerRadius(8)
        .padding()
    }
}
