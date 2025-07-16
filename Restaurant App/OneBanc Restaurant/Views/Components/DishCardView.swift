import SwiftUI

struct DishCardView: View {
    let dish: Dish
    let language: Language
    var onAdd: () -> Void
    var onRemove: () -> Void
    var showQuantity: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Dish Image with rating overlay
            ZStack(alignment: .bottomLeading) {
                Image(dish.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                // Rating indicator
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                    
                    Text(String(format: "%.1f", dish.rating))
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .padding(8)
            }
            
            // Dish name
            Text(dish.name)
                .font(.headline)
                .fontWeight(.medium)
                .padding(.top, 8)
                .padding(.horizontal, 8)
            
            // Price and add button
            HStack {
                Text("₹\(Int(dish.price))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                if showQuantity && dish.quantity > 0 {
                    HStack(spacing: 12) {
                        Button(action: onRemove) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 20))
                        }
                        
                        Text("\(dish.quantity)")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Button(action: onAdd) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 20))
                        }
                    }
                } else {
                    Button(action: onAdd) {
                        Text(language.addToCartText)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 4)
            .padding(.bottom, 12)
        }
        .frame(width: 220, height: 270)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#if DEBUG
struct DishCardView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample dish for preview
        let sampleDish = Dish(id: "sample1", name: "Sample Dish", image: "photo", price: 250, rating: 4.5, cuisineType: "Sample")
        
        DishCardView(
            dish: sampleDish,
            language: .english,
            onAdd: {},
            onRemove: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif 