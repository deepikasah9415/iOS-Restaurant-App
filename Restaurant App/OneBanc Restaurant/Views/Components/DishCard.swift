import SwiftUI

struct DishCard: View {
    let dish: Dish
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 12) {
                // Dish image
                ZStack(alignment: .topTrailing) {
                    if dish.image.hasPrefix("http") {
                        // Use our custom RemoteImage component for loading images from URLs
                        RemoteImage(url: dish.image, placeholder: Image(systemName: "photo"))
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(dish.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadiusLarge))
                .padding(.top, 8)
                
                // Dish name and rating
                HStack {
                    Text(dish.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primaryText)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Rating now beside dish name
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 13))
                        Text(String(format: "%.1f", dish.rating))
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.yellow.opacity(0.2))
                    .clipShape(Capsule())
                }
                
                // Price and quantity controls
                HStack {
                    Text("₹\(Int(dish.price))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryText)
                    
                    Spacer()
                    
                    // Quantity selector
                    HStack(spacing: 10) {
                        if let cartItem = viewModel.cart.items.first(where: { $0.id == dish.id }), cartItem.quantity > 0 {
                            // Quantity selector
                            Button(action: {
                                viewModel.removeFromCart(dish)
                            }) {
                                Circle()
                                    .fill(Color.actionRemove)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(systemName: "minus")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            Text("\(cartItem.quantity)")
                                .font(.headline)
                                .foregroundColor(Color.primaryText)
                                .frame(minWidth: 25)
                            
                            Button(action: {
                                viewModel.addToCart(dish)
                            }) {
                                Circle()
                                    .fill(Color.actionAdd)
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                        } else {
                            Button(action: {
                                viewModel.addToCart(dish)
                            }) {
                                Text(viewModel.selectedLanguage.addToCartText)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, UIConstants.paddingSmall)
                                    .padding(.vertical, 5)
                                    .background(Color.buttonPrimary)
                                    .cornerRadius(UIConstants.cornerRadiusSmall)
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            }
            .padding(UIConstants.paddingMedium)
            .background(Color.cardBackground)
            .cornerRadius(UIConstants.cornerRadiusLarge)
            .shadow(color: Color.standardShadow, radius: UIConstants.shadowRadius, x: 0, y: -UIConstants.shadowY)
            .shadow(color: Color.standardShadow, radius: UIConstants.shadowRadius, x: 0, y: UIConstants.shadowY)
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
struct DishCard_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample dish for preview
        let sampleDish = Dish(id: "sample1", name: "Sample Dish", image: "photo", price: 250, rating: 4.5, cuisineType: "Sample")
        
        DishCard(
            dish: sampleDish,
            viewModel: HomeViewModel()
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif 
