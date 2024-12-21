//
//  TaskPrioritiesView.swift
//
//
//  Created by Enes Karaosman on 19.12.2024.
//

import SwiftUI

struct TaskPrioritiesView: View {
    @StateObject
    private var viewModel = TasksViewModel()

    let logger = Logger.shared

    var body: some View {
        VStack {
            HStack {
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
                if let image2 = viewModel.image2 {
                    Image(uiImage: image2)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                }
            }
            .padding()

            LoggerView(logger: logger)
        }
        .onAppear {
            Task(priority: .low) {
                await logger.log("Low: \(Task.currentPriority)")
            }

            Task(priority: .medium) {
                await Task.yield() // we can also yield to certain priorities.
                await logger.log("Medium: \(Task.currentPriority)")
            }

            Task(priority: .high) {
                await logger.log("High: \(Task.currentPriority)")

                /*
                 Child tasks have the same priority and properties as the parent.
                 */
                Task {
                    await logger.log("Child task of high: \(Task.currentPriority)")
                }

                /*
                 Child tasks can also be detached, however it is not recommended by Apple.
                 */
                Task.detached() {
                    await logger.log("Child task.detached of high: \(Task.currentPriority)")
                }
            }

            Task(priority: .background) {
                await logger.log("Background: : \(Task.currentPriority)")
            }

            Task(priority: .utility) {
                await logger.log("Utility: \(Task.currentPriority)")
            }

            Task(priority: .userInitiated) {
                await logger.log("UserInitiated: \(Task.currentPriority)")
            }

            Task {
                await logger.log("Loading 1st img: \(Task.currentPriority)")
                await viewModel.fetchImage()
                await logger.log("Fetched 1st img: \(Task.currentPriority)")
            }

            Task {
                await logger.log("Loading 2nd img: \(Task.currentPriority)")
                await viewModel.fetchImage2()
                await logger.log("Fetched 2nd img: \(Task.currentPriority)")
            }
        }
    }
}

extension TaskPrioritiesView {
    final class TasksViewModel: ObservableObject {

        @Published var image: UIImage? = nil
        @Published var image2: UIImage? = nil

        func fetchImage() async {
            do {
                guard let url = URL(string: "https://picsum.photos/200") else { return }
                let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
                await MainActor.run {
                    let image = UIImage(data: data)
                    self.image = image
                }
            } catch {
                await Logger.shared.log(error.localizedDescription)
            }
        }

        func fetchImage2() async {
            do {
                guard let url = URL(string: "https://picsum.photos/200") else { return }
                let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
                await MainActor.run {
                    let image2 = UIImage(data: data)
                    self.image2 = image2
                }
            } catch {
                await Logger.shared.log(error.localizedDescription)
            }
        }
    }
}

#Preview {
    TaskPrioritiesView()
}
