import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Cart header
            HStack {
                // Back button
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                Text(viewModel.selectedLanguage.cartTitle)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryText)
                    .padding(.leading, 8)
                
                Spacer()
            }
            .padding(.horizontal, UIConstants.paddingStandard)
            .padding(.top, UIConstants.paddingSmall)
            .padding(.bottom, UIConstants.paddingStandard)
            
            if viewModel.cart.items.isEmpty {
                // Empty cart view
                emptyCartView
            } else {
                // Cart items
                ScrollView {
                    VStack(spacing: UIConstants.paddingStandard) {
                        ForEach(viewModel.cart.items) { item in
                            cartItemRow(item: item)
                        }
                    }
                    .padding(.horizontal, UIConstants.paddingStandard)
                    .padding(.bottom, UIConstants.paddingLarge)
                }
                
                // Summary card with bottom order button
                summaryCard
            }
        }
        .background(Color.pageBackground)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .alert(isPresented: .constant(viewModel.latestTransactionId != nil || viewModel.orderPlacementError != nil)) {
            if let txnId = viewModel.latestTransactionId {
                return Alert(
                    title: Text("Order Placed Successfully!"),
                    message: Text("Your TXN ID is \(txnId). Thank you!"),
                    dismissButton: .default(Text("OK")) {
                        viewModel.cart.clearCart()
                        viewModel.latestTransactionId = nil
                        dismiss()
                    }
                )
            } else if let errorMsg = viewModel.orderPlacementError {
                return Alert(
                    title: Text("Order Failed"),
                    message: Text(errorMsg),
                    dismissButton: .default(Text("OK")) {
                        viewModel.orderPlacementError = nil
                    }
                )
            } else {
                return Alert(title: Text("Unknown State"))
            }
        }
    }
    
    // MARK: - Cart Item Row
    private func cartItemRow(item: CartItem) -> some View {
        HStack(spacing: UIConstants.paddingStandard) {
            // Dish image
            if item.dish.image.hasPrefix("http") {
                RemoteImage(url: item.dish.image, placeholder: Image(systemName: "photo"))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadiusMedium))
            } else {
                Image(item.dish.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadiusMedium))
            }
            
            // Dish details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.dish.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.primaryText)
                
                Text("₹\(Int(item.dish.price))")
                    .font(.headline)
                    .foregroundColor(Color.primaryText.opacity(0.7))
                
                Text(item.dish.cuisineType)
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryText)
            }
            
            Spacer()
            
            // Quantity controls with circles
            HStack(spacing: 8) {
                Button(action: {
                    viewModel.removeFromCart(item.dish)
                }) {
                    Circle()
                        .fill(Color.actionRemove)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "minus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
                
                Text("\(item.quantity)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(width: 30, alignment: .center)
                
                Button(action: {
                    viewModel.addToCart(item.dish)
                }) {
                    Circle()
                        .fill(Color.actionAdd)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding(.vertical, UIConstants.paddingStandard)
        .padding(.horizontal, UIConstants.paddingStandard)
        .background(Color.white)
        .cornerRadius(UIConstants.cornerRadiusMedium)
        .shadow(color: Color.standardShadow, radius: UIConstants.shadowRadius, x: 0, y: UIConstants.shadowY)
    }
    
    // MARK: - Empty Cart View
    private var emptyCartView: some View {
        VStack(spacing: UIConstants.paddingLarge) {
            Spacer()
            
            ZStack(alignment: .topTrailing) {
                Image(systemName: "cart")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                    .padding(.top, 8)

                if viewModel.cart.items.count > 0 {
                    Text("\(viewModel.cart.items.count)")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 8, y: -8)
                }
            }
            
            Text(viewModel.selectedLanguage.emptyCartText)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(Color.secondaryText)
            
            Button(action: {
                dismiss()
            }) {
                Text("Continue Shopping")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.buttonPrimary)
                    .cornerRadius(UIConstants.cornerRadiusMedium)
                    .padding(.horizontal, UIConstants.paddingLarge)
                    .shadow(color: Color.primaryGreen.opacity(0.4), radius: UIConstants.shadowRadius, x: 0, y: UIConstants.shadowY)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Summary Card
    private var summaryCard: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: UIConstants.paddingStandard) {
                // Total
                HStack {
                    Text("Total")
                        .font(.headline)
                        .foregroundColor(Color.primaryText)
                    
                    Spacer()
                    
                    Text("₹\(Int(viewModel.cart.totalPrice))")
                        .font(.headline)
                        .foregroundColor(Color.primaryText)
                }
                .padding(.top, UIConstants.paddingStandard)
                
                // CGST
                HStack {
                    Text("CGST (2.5%)")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                    
                    Spacer()
                    
                    Text("₹\(String(format: "%.2f", viewModel.cart.cgst))")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                }
                
                // SGST
                HStack {
                    Text("SGST (2.5%)")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                    
                    Spacer()
                    
                    Text("₹\(String(format: "%.2f", viewModel.cart.sgst))")
                        .font(.subheadline)
                        .foregroundColor(Color.secondaryText)
                }
                
                Divider()
                    .padding(.vertical, UIConstants.paddingSmall)
                
                // Grand total
                HStack {
                    Text("Grand Total")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryText)
                    
                    Spacer()
                    
                    Text("₹\(String(format: "%.2f", viewModel.cart.grandTotal))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primaryText)
                }
                .padding(.bottom, UIConstants.paddingStandard)
            }
            .padding(.horizontal, UIConstants.paddingStandard)
            
            // Place order button - Full width with green background
            Button(action: {
                viewModel.placeOrder()
            }) {
                if viewModel.isLoading {
                    HStack {
                        Text("Placing Order...")
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, UIConstants.paddingStandard)
                    .background(Color.buttonPrimary.opacity(0.7))
                    .cornerRadius(0)
                } else {
                    Text("Place Order")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, UIConstants.paddingStandard)
                        .background(Color.buttonPrimary)
                        .cornerRadius(0)
                }
            }
            .disabled(viewModel.isLoading)
        }
        .background(Color.white)
    }
}

#if DEBUG
struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(viewModel: HomeViewModel())
    }
}
#endif 