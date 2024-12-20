import SwiftUI

struct CallbackToContinuationsView: View {
    
    @State
    private var messages: UIState<[Message]> = .initial

    var body: some View {
        NavigationStack {
            List {
                StateView(state: $messages) { messages in
                    ForEach(messages, id: \.id) { message in
                        VStack(alignment: .leading) {
                            Text(message.from)
                                .font(.headline)

                            Text(message.message)
                        }
                    }
                }
            }
            .task {
                do {
                    messages = .loading
                    messages = .success(try await fetchThrowingMessages())
                } catch {
                    messages = .error("Error fetching messages")
                }
            }
        }
    }
    
    func fetchMessages(completion: @escaping ([Message]) -> Void) {
        let url = URL(string: "https://hws.dev/user-messages.json")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data {
                if let messages = try? JSONDecoder().decode([Message].self, from: data) {
                    completion(messages)
                    return
                }
            }

            completion([])
        }.resume()
    }
    
    func fetchMessages() async -> [Message] {
        return await withCheckedContinuation { continuation in
            fetchMessages { messages in
                continuation.resume(returning: messages)
            }
        }
    }
    
    func fetchThrowingMessages() async throws -> [Message] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchMessages { messages in
                if messages.isEmpty {
                    continuation.resume(throwing: FetchError.noMessages)
                } else {
                    continuation.resume(returning: messages)
                }
            }
        }
    }
    
}

#Preview {
    CallbackToContinuationsView()
}


enum FetchError: Error {
    case noMessages
}

struct Message: Decodable {
    let id: Int
    let from: String
    let message: String
}
