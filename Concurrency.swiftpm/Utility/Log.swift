//
//  Log.swift
//
//
//  Created by Enes Karaosman on 20.12.2024.
//

import Combine
import Foundation
import SwiftUI

actor Logger {
    static let shared = Logger()

    struct Log {
        let id = UUID().uuidString
        let message: String
    }

    // Internal storage for log messages
    private var logs: [Log] = []

    // AsyncStream continuation to publish messages
    private var continuation: AsyncStream<Log>.Continuation?

    // Lazy initialization for the AsyncStream to avoid capturing `self` prematurely
    lazy var logStream: AsyncStream<Log> = .init { continuation in
        self.continuation = continuation
    }

    // Method to log a message
    func log(_ message: String) {
        let debugMessage = debugDate() + message
        let log = Log(message: debugMessage)
        logs.append(log)
        continuation?.yield(log)
        print(debugMessage)
    }

    // Retrieve all logged messages
    func getAllLogs() -> [String] {
        return logs.map(\.message)
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

    init(logger: Logger = .shared) {
        self.logger = logger
    }

    @State
    private var logs: [Logger.Log] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Logs;")
                        .fontWeight(.bold)
                    Spacer()
                    Button("Clear") {
                        Task {
                            withAnimation {
                                logs.removeAll()
                            }
                            await logger.clear()
                        }
                    }
                    .foregroundColor(.red)
                }
                ForEach(logs, id: \.id) { log in
                    Text(log.message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .font(.system(.footnote, design: .monospaced))
            .foregroundColor(.white)
            .task {
                for await log in await logger.logStream {
                    logs.append(log)
                }
            }
            .padding(8)
            .background(Color.black.opacity(0.7))
            .cornerRadius(8)
            .padding(8)
        }
        .onDisappear {
            Task { await logger.clear() }
        }
    }
}

extension State {
    @propertyWrapper
    struct Logged: DynamicProperty {
        @State private var value: Value
        private let logger: Logger

        var wrappedValue: Value {
            get { value }
            nonmutating set {  // Make this nonmutating to comply with @State's immutability
                Task { await logger.log("\(newValue)") }
                value = newValue
            }
        }

        var projectedValue: Binding<Value> {
            Binding(get: { self.value }, set: { newValue in
                Task { await logger.log("\(newValue)") }
                self.value = newValue
            })
        }

        init(wrappedValue: Value, logger: Logger = Logger.shared) {
            _value = State(wrappedValue: wrappedValue)
            self.logger = logger
        }
    }
}
