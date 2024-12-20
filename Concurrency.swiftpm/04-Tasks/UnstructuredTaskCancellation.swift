import SwiftUI

struct UnstructuredTaskCancellationView: View {
    @StateObject private var task = UnstructuredTaskCancellationViewModel()

    var body: some View {
        VStack {
            Text("Task status: ")
            Button("Cancel task") {
                // Cancel the task
            }
        }
    }
}

extension UnstructuredTaskCancellationView {
    final class UnstructuredTaskCancellationViewModel: ObservableObject {
        @Published
        private(set) var taskStatus: String = "Initial"

        private var task: Task<Void, Never>?

        func load() {
            task = Task {
                do {
                    try await Task.sleep(for: .seconds(5))
                } catch {
                    taskStatus = "Cancelled"
                }
            }
        }
    }
}
