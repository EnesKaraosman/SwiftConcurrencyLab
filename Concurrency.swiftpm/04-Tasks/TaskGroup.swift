import SwiftUI

struct TaskGroupView: View {

    @StateObject
    private var viewModel = ViewModel()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .task {
            await viewModel.getImages()
        }
    }
}

extension TaskGroupView {
    final class ViewModel: ObservableObject {
        @Published var images: [UIImage] = []

        func getImages() async {
            if let images = try? await fetchImagesWithTaskGroup() {
                await MainActor.run {
                    self.images.append(contentsOf: images)
                }
            }
        }

        func fetchImagesWithTaskGroup() async throws -> [UIImage] {
            let urlStrings = Array(repeating: "https://picsum.photos/300", count: 10)

            return try await withThrowingTaskGroup(of: UIImage.self) { group in
                urlStrings.enumerated().forEach { index, urlString in
                    group.addTask {
                        try await self.fetchImage(urlString: urlString, for: index)
                    }
                }

                return try await group.reduce(into: [UIImage]()) {
                    $0 += [$1]
                }
            }
        }

        func fetchImage(urlString: String, for index: Int) async throws -> UIImage {
            guard let url = URL(string: urlString) else {
                throw "BadURL"
            }

            print(debugDate(), "Started \(index)")
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            print(debugDate(), "Finished \(index)")

            guard let image = UIImage(data: data) else {
                throw "InvalidImage"
            }

            return image
        }
    }
}

#Preview {
    TaskGroupView()
}
