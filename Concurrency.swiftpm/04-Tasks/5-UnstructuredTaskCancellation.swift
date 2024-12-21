import SwiftUI

struct UnstructuredTaskCancellationView: View {
    @StateObject
    private var vm = UnstructuredTaskCancellationViewModel()

    var body: some View {
        List {
            Text("Task status: \(vm.taskStatus)")

            Button("Run task") {
                vm.load()
            }

            Button("Cancel task") {
                vm.cancel()
            }
        }
    }
}

extension UnstructuredTaskCancellationView {
    final class UnstructuredTaskCancellationViewModel: ObservableObject {
        @Published @MainActor
        private(set) var taskStatus: UIState<String> = .initial {
            didSet {
                Task { await Logger.shared.log("\(taskStatus)") }
            }
        }

        deinit {
            print("Deinit \(Self.self)")
//            cancel()
        }

        private var task: Task<Void, Never>?

        func load() {
            task = Task { @MainActor in
                do {
                    taskStatus = .loading
                    try await Task.sleep(for: .seconds(5))
                    taskStatus = .success("Finished")
                } catch {
                    taskStatus = .error("Cancelled")
                }
            }
        }

        func cancel() {
            task?.cancel()
            task = nil
        }
    }
}
