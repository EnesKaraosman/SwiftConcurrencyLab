//
//  AsyncAwait.swift
//
//
//  Created by Enes Karaosman on 19.12.2024.
//

import SwiftUI

struct AsyncAwaitView: View {
    @State
    private var data: UIState<String> = .initial

    @State
    private var data2: UIState<String> = .initial

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Fetch using .task")
                    Spacer()
                    StateView(state: $data) { data in
                        Text(data)
                    }
                }
                .task {
                    do {
                        data = .loading
                        let fetchedData = try await fetchData()
                        data = .success(fetchedData)
                    } catch {
                        data = .error("Error fetching data")
                    }
                }
            }

            Section (content: {
                StateView(state: $data2) { data in
                    Text(data)
                }
            }, footer: {
                Button("Fetch Data") {
                    Task {
                        do {
                            data2 = .loading
                            let fetchedData = try await fetchData()
                            data2 = .success(fetchedData)
                        } catch {
                            data2 = .error("Error fetching data")
                        }
                    }
                }
            })
        }
    }

    func fetchData() async throws -> String {
        // Simulating a network request delay
        try await Task.sleep(for: .seconds(1))

        if Bool.random() {
            return "Data fetched successfully!"
        }

        throw "Network error occured"
    }
}

#Preview {
    AsyncAwaitView()
}
