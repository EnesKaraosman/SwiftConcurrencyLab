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

    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            if let image2 = viewModel.image2 {
                Image(uiImage: image2)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .onAppear {
            Task(priority: .low) {
                print("Low: \(Task.currentPriority)")
            }

            Task(priority: .medium) {
                await Task.yield() // we can also yield to certain priorities.
                print("Medium: \(Task.currentPriority)")
            }

            Task(priority: .high) {
                print("High: \(Task.currentPriority)")

                /*
                 Child tasks have the same priority and properties as the parent.
                 */
                Task {
                    print("Child task of high: \(Task.currentPriority)")
                }

                /*
                 Child tasks can also be detached, however it is not recommended by Apple.
                 */
                Task.detached() {
                    print("Child task.detached of high: \(Task.currentPriority)")
                }
            }

            Task(priority: .background) {
                print("Background: : \(Task.currentPriority)")
            }

            Task(priority: .utility) {
                print("Utility: \(Task.currentPriority)")
            }

            Task(priority: .userInitiated) {
                print("UserInitiated: \(Task.currentPriority)")
            }

            Task {
                await viewModel.fetchImage()
                print("Fetched first Image: \(Task.currentPriority)")
            }
            Task { // we can have multiple tasks running at the same time.
                await viewModel.fetchImage2()
                print("Fetched second Image: \(Task.currentPriority)")
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
                print(error.localizedDescription)
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
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    TaskPrioritiesView()
}
