//
//  AsyncLet.swift
//
//
//  Created by Enes Karaosman on 19.12.2024.
//

import SwiftUI

struct AsyncLetTasksView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        List {
            Section(content: {
                HStack {
                    Text("First task:")
                    Spacer()
                    StateView(state: $viewModel.first) { text in
                        Text(text)
                    }
                }

                HStack {
                    Text("Second task:")
                    Spacer()
                    StateView(state: $viewModel.second) { text in
                        Text(text)
                    }
                }
            }, footer: {
                Button("Start 2 task concurrently") {
                    viewModel.run()
                }
            })
        }
    }
}

extension AsyncLetTasksView {
    final class ViewModel: ObservableObject {
        @Published
        var first: UIState<String> = .initial

        @Published
        var second: UIState<String> = .initial

        private var task: Task<Void, Never>?
        
        func run() {
            Task {
                async let firstResult = getFirst()
                async let secondResult = getSecond()

                let (first, second) = try await (firstResult, secondResult)
                self.first = .success(first)
                self.second = .success(second)
            }
        }

        func getFirst() async throws -> String {
            first = .loading
            try await Task.sleep(for: .seconds(1))
            return "Completed"
        }

        func getSecond() async throws -> String {
            second = .loading
            try await Task.sleep(for: .seconds(2))
            return "Completed"
        }
    }
}

#Preview {
    AsyncLetTasksView()
}
