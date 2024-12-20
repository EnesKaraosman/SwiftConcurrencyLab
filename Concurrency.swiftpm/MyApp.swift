import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                Form {
                    Section(content: {
                        NavigationLink("Basic", destination: {
                            NavigationLazyView { AsyncAwaitView() }
                        })
                        NavigationLink("Async Let", destination: {
                            NavigationLazyView { AsyncLetTasksView() }
                        })
                    }, header: {
                        Text("Getting Started")
                    })

                    Section(content: {
                        NavigationLink("AsyncSequence", destination: {
                            NavigationLazyView { AsyncSequenceView() }
                        })
                        NavigationLink("AsyncStream", destination: {
                            NavigationLazyView { AsyncStreamView() }
                        })
                    }, header: {
                        Text("AsyncSequence & AsyncStream")
                    })

                    Section(content: {
                        NavigationLink("Callback to Continuations", destination: {
                            NavigationLazyView { CallbackToContinuationsView() }
                        })
                        NavigationLink("Delegate to Continuations", destination: {
                            NavigationLazyView { DelegateToContinuationsView() }
                        })
                    }, header: {
                        Text("Intermediate")
                    })

                    Section (content: {
                        NavigationLink("Task Group", destination: {
                            NavigationLazyView { TaskGroupView() }
                        })
                        NavigationLink("Task Priority", destination: {
                            NavigationLazyView { TaskPrioritiesView() }
                        })
                        NavigationLink("Task Cancellation", destination: {
                            NavigationLazyView { TaskCancellationView() }
                        })
                    }, header: {
                        Text("Tasks")
                    })
                }
            }
        }
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
