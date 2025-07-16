import SwiftUI

struct OrderHistoryView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    
    var body: some View {
        VStack {
            if homeViewModel.orderHistory.isEmpty {
                emptyStateView
            } else {
                ordersList
            }
        }
        .navigationTitle("Order History")
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "bag")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("No Previous Orders")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Your order history will appear here")
                .foregroundColor(.gray)
            
            Spacer()
        }
        .padding()
    }
    
    private var ordersList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(homeViewModel.orderHistory) { order in
                    OrderHistoryCard(order: order)
                }
            }
            .padding()
        }
    }
}

struct OrderHistoryCard: View {
    let order: OrderRecord
    @State private var isExpanded = false
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: order.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Order #\(order.transactionId.prefix(8))")
                        .font(.headline)
                    
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            Divider()
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Items:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ForEach(order.items) { cartItem in
                        HStack {
                            Text("• \(cartItem.dish.name) (x\(cartItem.quantity))")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("₹\(cartItem.dish.price * Double(cartItem.quantity), specifier: "%.2f")")
                                .font(.subheadline)
                        }
                    }
                    
                    Divider()
                }
            }
            
            HStack {
                Text("Grand Total")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("₹\(order.grandTotal, specifier: "%.2f")")
                    .font(.headline)
            }
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(isExpanded ? "Show Less" : "Show Details")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#if DEBUG
struct OrderHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = HomeViewModel()
        
        let sampleDish1 = Dish(id: "sample1", name: "Sample Dish 1", image: "photo", price: 250, rating: 4.5, cuisineType: "Sample")
        let sampleDish2 = Dish(id: "sample2", name: "Sample Dish 2", image: "photo", price: 350, rating: 4.2, cuisineType: "Sample")
        
        let sampleCartItem1 = CartItem(dish: sampleDish1, quantity: 1)
        let sampleCartItem2 = CartItem(dish: sampleDish2, quantity: 2)
        
        let sampleOrderRecord1 = OrderRecord(
            id: "TXNPREV123", 
            transactionId: "TXNPREV123", 
            items: [sampleCartItem1, sampleCartItem2], 
            grandTotal: 950.0,
            date: Date()
        )
        
        let sampleOrderRecord2 = OrderRecord(
            id: "TXNPREV456", 
            transactionId: "TXNPREV456", 
            items: [sampleCartItem1], 
            grandTotal: 250.0, 
            date: Date().addingTimeInterval(-86400 * 2)
        )
        
        viewModel.orderHistory = [sampleOrderRecord1, sampleOrderRecord2]
        
        return NavigationView {
            OrderHistoryView(homeViewModel: viewModel)
        }
    }
}
#endif
