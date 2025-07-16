import SwiftUI

struct CuisineCardView: View {
    let cuisine: Cuisine
    
    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                // Cuisine Image
                if cuisine.image.hasPrefix("http") {
                    // Use our custom RemoteImage component for loading images from URLs
                    RemoteImage(url: cuisine.image, placeholder: Image(systemName: "photo"))
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(cuisine.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [Color.overlayGradientLight, Color.overlayGradientDark]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Cuisine name
                Text(cuisine.name)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 2)
            }
            .frame(width: 350, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadiusExtraLarge))
        }
        .frame(width: 350, height: 200)
        .shadow(color: Color.standardShadow, radius: UIConstants.shadowRadius, x: 0, y: UIConstants.shadowY)
    }
}

#if DEBUG
struct CuisineCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample cuisine for preview
        let sampleDishes = [
            Dish(id: "sample1", name: "Sample Dish 1", image: "photo", price: 250, rating: 4.5, cuisineType: "Sample"),
            Dish(id: "sample2", name: "Sample Dish 2", image: "photo", price: 350, rating: 4.2, cuisineType: "Sample")
        ]
        let sampleCuisine = Cuisine(id: "1", name: "Sample Cuisine", image: "photo", dishes: sampleDishes)
        
        CuisineCardView(cuisine: sampleCuisine)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif 