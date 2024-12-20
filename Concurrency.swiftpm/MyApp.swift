import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Form {
                    Section(content: {
                        NavigationLink("Basic", destination: {
                            AsyncAwaitView()
                        })
                        NavigationLink("Async Let", destination: {
                            AsyncLetTasksView()
                        })
                    }, header: {
                        Text("Getting Started")
                    })

                    Section(content: {
                        NavigationLink("AsyncSequence", destination: {
                            AsyncSequenceView()
                        })
                        NavigationLink("AsyncStream", destination: {
                            AsyncStreamView()
                        })
                    }, header: {
                        Text("AsyncSequence & AsyncStream")
                    })

                    Section(content: {
                        NavigationLink("Callback to Continuations", destination: {
                            CallbackToContinuationsView()
                        })
                        NavigationLink("Delegate to Continuations", destination: {
                            DelegateToContinuationsView()
                        })
                    }, header: {
                        Text("Intermediate")
                    })

                    Section (content: {
                        NavigationLink("Task Group", destination: {
                            TaskGroupView()
                        })
                        NavigationLink("Task Priority", destination: {
                            TaskPrioritiesView()
                        })
                        NavigationLink("Task Cancellation", destination: {
                            TaskCancellationView()
                        })
                    }, header: {
                        Text("Tasks")
                    })
                }
            }
        }
    }
}
