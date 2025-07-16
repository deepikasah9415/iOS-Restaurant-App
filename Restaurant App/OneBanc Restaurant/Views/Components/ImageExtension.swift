import SwiftUI

extension Image {
    static func dish(_ name: String) -> Image {
        // Try to load from assets, fallback to placeholder if not found
        if UIImage(named: name) != nil {
            return Image(name)
        } else {
            return Image(systemName: "photo")
        }
    }
    
    static func cuisine(_ name: String) -> Image {
        // Try to load from assets, fallback to placeholder if not found
        if UIImage(named: name) != nil {
            return Image(name)
        } else {
            return Image(systemName: "photo")
        }
    }
}

extension String {
    var asImage: Image {
        // If this is a URL, we'll let AsyncImage handle it
        if self.hasPrefix("http") {
            return Image(systemName: "photo")
        }
        
        // Otherwise try to load from assets
        if UIImage(named: self) != nil {
            return Image(self)
        }
        
        // Fallback to placeholder
        return Image(systemName: "photo")
    }
}