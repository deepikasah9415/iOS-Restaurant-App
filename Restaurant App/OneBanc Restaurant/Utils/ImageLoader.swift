import Foundation
import SwiftUI
import Combine

// Image loader for downloading and caching images from URLs
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    private var url: URL?
    private var cancellable: AnyCancellable?
    private static let imageCache = NSCache<NSString, UIImage>()
    
    init(url: URL?) {
        self.url = url
    }
    
    func load() {
        guard let url = url else { return }
        
        // Check if the image is cached
        if let cachedImage = ImageLoader.imageCache.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loadedImage in
                guard let self = self, let loadedImage = loadedImage else { return }
                self.image = loadedImage
                self.isLoading = false
                // Cache the downloaded image
                ImageLoader.imageCache.setObject(loadedImage, forKey: url.absoluteString as NSString)
            }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
}

// SwiftUI View for loading and displaying remote images with a placeholder
struct RemoteImage: View {
    private enum LoadState {
        case loading, success, failure
    }
    
    private class Loader: ObservableObject {
        var imageLoader: ImageLoader?
        @Published var state = LoadState.loading
        @Published var image: UIImage?
        
        init(url: URL?) {
            guard let url = url else {
                state = .failure
                return
            }
            
            imageLoader = ImageLoader(url: url)
            imageLoader?.load()
            
            DispatchQueue.main.async {
                if self.imageLoader?.image != nil {
                    self.image = self.imageLoader?.image
                    self.state = .success
                }
            }
            
            imageLoader?.$image
                .sink { [weak self] image in
                    self?.image = image
                    self?.state = image != nil ? .success : .failure
                }
                .store(in: &cancellables)
        }
        
        func cancel() {
            imageLoader?.cancel()
        }
        
        private var cancellables = Set<AnyCancellable>()
    }
    
    @StateObject private var loader: Loader
    private let placeholder: Image
    
    init(url: String?, placeholder: Image = Image(systemName: "photo")) {
        let url = url != nil ? URL(string: url!) : nil
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.placeholder = placeholder
    }
    
    var body: some View {
        selectImage()
            .resizable()
            .aspectRatio(contentMode: .fill)
            .onDisappear {
                loader.cancel()
            }
    }
    
    private func selectImage() -> Image {
        switch loader.state {
        case .loading:
            return placeholder
        case .success:
            if let image = loader.image {
                return Image(uiImage: image)
            } else {
                return placeholder
            }
        case .failure:
            return placeholder
        }
    }
}

// SwiftUI extension to easily create remote images
extension Image {
    static func remote(_ urlString: String, placeholder: Image = Image(systemName: "photo")) -> some View {
        RemoteImage(url: urlString, placeholder: placeholder)
    }
}
