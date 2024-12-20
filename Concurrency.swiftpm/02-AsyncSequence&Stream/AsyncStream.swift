//
//  AsyncStreamView.swift
//
//
//  Created by Enes Karaosman on 20.12.2024.
//

import SwiftUI

extension NotificationCenter {
    func notifications(for name: Notification.Name) -> AsyncStream<Notification> {
        AsyncStream<Notification> { continuation in
            NotificationCenter.default.addObserver(
                forName: name,
                object: nil,
                queue: nil
            ) { notification in
                continuation.yield(notification)
                // continuation.finish()
            }
        }
    }
}

// warningi gidermek icin insiyatif almamiz gerekiyor
//extension Notification: @unchecked Sendable {}

struct AsyncStreamView: View {
    @State.Logged
    private var didEnterBackgroundNotification = ""

    @State.Logged
    private var streamedPhrase = ""

    var body: some View {
        List {
            Section {
                Text(didEnterBackgroundNotification)
            }
            .onAppear {
                Task {
                    for await _ in NotificationCenter.default
                        .notifications(for: UIApplication.didEnterBackgroundNotification) {
                        didEnterBackgroundNotification = "didEnterBackgroundNotification"
                    }
                }
            }

            Section {
                Text(streamedPhrase)
            }
            .task {
                await streamWord("Hello, World!")
            }
        }
    }

    func streamWord(_ phrase: String) async {
        var index = phrase.startIndex
        let stream = AsyncStream<String> {
            guard index < phrase.endIndex else { return nil }
            do {
                try await Task.sleep(for: .milliseconds(200))
            } catch {
                return nil
            }
            let result = String(phrase[phrase.startIndex...index])
            index = phrase.index(after: index)
            return result
        }

        for try await item in stream {
            streamedPhrase = item
        }
    }
}

#Preview {
    AsyncStreamView()
}
