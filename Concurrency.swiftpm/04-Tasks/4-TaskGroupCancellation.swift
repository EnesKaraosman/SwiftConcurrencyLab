import SwiftUI

struct TaskGroupCancellationView: View {
    let logger = Logger.shared

    var body: some View {
        VStack {
            LoggerView(logger: logger)
        }.task {
            await printMessage()
        }
    }

    private func printMessage() async {
        let result = await withThrowingTaskGroup(of: String.self) { group in
            group.addTask { "Testing" }
//            group.addTask {
//                try Task.checkCancellation()
//                return "Testing"
//            }

            group.addTask { "Group" }
            group.addTask { "Cancellation" }

            group.cancelAll()
            var collected = [String]()

            do {
                for try await value in group {
                    collected.append(value)
                    await logger.log(value)
                }
            } catch {
                await logger.log(error.localizedDescription)
            }

            return collected.joined(separator: " ")
        }

        await logger.log("Result: \(result)")
    }
}
