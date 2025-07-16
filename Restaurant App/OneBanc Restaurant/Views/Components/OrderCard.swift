import SwiftUI

struct OrderCard: View {
    let order: Order
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: UIConstants.paddingMedium) {
                // Order date with receipt icon
                HStack {
                    Image(systemName: "receipt")
                        .font(.system(size: 16))
                        .foregroundColor(Color.primaryGreen)
                    
                    Text(order.formattedDate)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primaryText)
                }
                .padding(.top, 8)
                
                Divider()
                
                // Order items (showing just the first one)
                VStack(alignment: .leading, spacing: 4) {
                    Text(order.items[0].name)
                        .font(.headline)
                        .foregroundColor(Color.primaryText)
                        .lineLimit(1)
                    
                    if order.items.count > 1 {
                        Text("+ \(order.items.count - 1) more item\(order.items.count - 1 > 1 ? "s" : "")")
                            .font(.caption)
                            .foregroundColor(Color.secondaryText)
                    }
                }
                
                Spacer()
                
                // Total amount and status
                HStack {
                    Text("₹\(Int(order.totalAmount))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryText)
                    
                    Spacer()
                    
                    // Order status pill
                    Text(order.orderStatus.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, UIConstants.paddingSmall)
                        .padding(.vertical, 5)
                        .background(order.orderStatus.color)
                        .cornerRadius(UIConstants.cornerRadiusMedium)
                }
                .padding(.bottom, 8)
            }
            .padding(UIConstants.paddingStandard)
            .background(Color.cardBackground)
            .cornerRadius(UIConstants.cornerRadiusLarge)
            .shadow(color: Color.standardShadow, radius: UIConstants.shadowRadius, x: 0, y: -UIConstants.shadowY)
            .shadow(color: Color.standardShadow, radius: UIConstants.shadowRadius, x: 0, y: UIConstants.shadowY)
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
struct OrderCard_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample order for preview
        let sampleDishes = [
            Dish(id: "sample1", name: "Sample Dish", image: "photo", price: 250, rating: 4.5, cuisineType: "Sample")
        ]
        let sampleOrder = Order(
            items: sampleDishes,
            orderDate: Date(),
            totalAmount: 250.0,
            orderStatus: .completed
        )
        
        OrderCard(order: sampleOrder)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif 