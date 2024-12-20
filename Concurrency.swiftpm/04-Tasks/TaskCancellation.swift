import SwiftUI

struct TaskCancellationView: View {
    let iterationCount = 10

    @State
    private var messages = [String]()

    let logger = Logger()

    var body: some View {
        VStack {
            Text("Iteration count: \(iterationCount)")

            Divider()

            LoggerView(logger: logger)
        }.task {
            await simpleTaskCancellation()
        }
    }

    private func simpleTaskCancellation() async {
        let task = Task.detached {
            for i in 1...iterationCount {
                guard !Task.isCancelled else {
                    await logger.log("Task was cancelled!")
                    return
                }

                await logger.log("Processing \(i)...")
                try? await Task.sleep(for: .seconds(0.5))
            }

            await logger.log("Task completed.")
        }

        try? await Task.sleep(for: .seconds(2))
        task.cancel()

        await logger.log("Task canceled!")
    }
}
