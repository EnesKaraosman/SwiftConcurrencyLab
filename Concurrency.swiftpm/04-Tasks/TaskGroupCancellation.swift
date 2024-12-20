import SwiftUI

struct TaskGroupCancellation: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }.task {
            func printMessage() async {
                let result = await withThrowingTaskGroup(of: String.self) { group in
                    group.addTask { "Testing" }
//                    group.addTask {
//                        try Task.checkCancellation()
//                        return "Testing"
//                    }
                    
                    group.addTask { "Group" }
                    group.addTask { "Cancellation" }

                    group.cancelAll()
                    var collected = [String]()

                    do {
                        for try await value in group {
                            collected.append(value)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }

                    return collected.joined(separator: " ")
                }

                print(result)
            }

            await printMessage()
        }
    }
}
