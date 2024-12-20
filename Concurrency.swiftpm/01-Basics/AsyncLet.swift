import SwiftUI

struct AsyncLetTasksView: View {

    @State.Logged
    var first: UIState<String> = .initial

    @State.Logged
    var second: UIState<String> = .initial

    var body: some View {
        VStack {
            List {
                Section(content: {
                    HStack {
                        Text("First task:")
                        Spacer()
                        StateView(state: $first) { text in
                            Text(text)
                        }
                    }

                    HStack {
                        Text("Second task:")
                        Spacer()
                        StateView(state: $second) { text in
                            Text(text)
                        }
                    }
                }, footer: {
                    Button("Start 2 task concurrently") {
                        run()
                    }
                })
            }
        }
    }

    func run() {
        Task {
            async let firstResult = getFirst()
            async let secondResult = getSecond()

            let (first, second) = try await (firstResult, secondResult)

            await MainActor.run {
                self.first = .success(first)
                self.second = .success(second)
            }
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

#Preview {
    AsyncLetTasksView()
}
