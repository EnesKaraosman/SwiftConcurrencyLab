//
//  AsyncSequenceView.swift
//
//
//  Created by Enes Karaosman on 20.12.2024.
//

import SwiftUI

struct AsyncSequenceView: View {

    @State private var lines = [String]()

    var body: some View {
        List {
            ForEach(lines, id: \.self) { line in
                Text(line)
            }
        }
        .task {
//            try? await fetchUsers()
            try? await printUsers()
        }
    }

    func fetchUsers() async throws {
        let url = URL(string: "https://hws.dev/users.csv")!

        for try await line in url.lines {
            let parts = line.split(separator: ",")
            guard parts.count == 4 else { continue }

            guard let id = Int(parts[0]) else { continue }
            let firstName = parts[1]
            let lastName = parts[2]
            let country = parts[3]

            lines.append("Found user #\(id): \(firstName) \(lastName) from \(country)")

            try? await Task.sleep(for: .milliseconds(250))
        }
    }

    func printUsers() async throws {
        let url = URL(string: "https://hws.dev/users.csv")!

        var iterator = url.lines.makeAsyncIterator()

        if let line = try await iterator.next() {
            lines.append("The first user is \(line)")
        }

        while let result = try await iterator.next() {
            lines.append(result)
            try? await Task.sleep(for: .milliseconds(250))
        }
    }

}

#Preview {
    AsyncSequenceView()
}
