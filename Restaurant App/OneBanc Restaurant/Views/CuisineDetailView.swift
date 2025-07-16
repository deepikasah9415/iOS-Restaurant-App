import SwiftUI

struct CuisineDetailView: View {
    @StateObject private var viewModel: CuisineViewModel
    @ObservedObject var homeViewModel: HomeViewModel
    
    init(cuisine: Cuisine, homeViewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: CuisineViewModel(cuisine: cuisine))
        self.homeViewModel = homeViewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with cuisine information
                cuisineHeader
                
                // Loading indicator
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                        Spacer()
                    }
                }
                
                // Error message if any
                if let errorMessage = viewModel.errorMessage {
                    VStack(alignment: .center, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .padding(.bottom, 4)
                        
                        Text(errorMessage)
                            .font(.headline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            
                        Text("Please try again later or check your internet connection")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            
                        // Show the fallback dishes if available
                        if !viewModel.dishes.isEmpty {
                            Text("Showing available dishes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 4)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // List of dishes for this cuisine
                dishesGrid
            }
            .padding(.horizontal)
        }
        .onAppear {
            // Fetch dishes for this specific cuisine when the view appears
            viewModel.fetchDishesByCuisineType()
        }
        .navigationTitle(viewModel.selectedCuisine.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: CartView(viewModel: homeViewModel)) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "cart")
                            .font(.system(size: 22))
                            .foregroundColor(.green)
                        
                        if !homeViewModel.cart.items.isEmpty {
                            Text("\(homeViewModel.cart.items.count)")
                                .font(.caption2)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 18, height: 18)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 10, y: -10)
                        }
                    }
                    .padding(.trailing, 8)
                    .padding(.top, 4)
                }
            }
        }
    }
    
    // MARK: - Cuisine Header
    private var cuisineHeader: some View {
        ZStack(alignment: .bottom) {
            // Cuisine Image
            if viewModel.selectedCuisine.image.hasPrefix("http") {
                // Use our custom RemoteImage component for loading images from URLs
                RemoteImage(url: viewModel.selectedCuisine.image, placeholder: Image(systemName: "photo"))
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                Image(viewModel.selectedCuisine.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Cuisine name
            Text(viewModel.selectedCuisine.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 16)
                .padding(.horizontal)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Dishes Grid
    private var dishesGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(viewModel.dishes) { dish in
                    if let cartItem = homeViewModel.cart.items.first(where: { $0.id == dish.id }) {
                        DishCard(
                            dish: cartItem.dish,
                            viewModel: homeViewModel
                        )
                        .frame(maxWidth: .infinity)
                    } else {
                        DishCard(
                            dish: dish,
                            viewModel: homeViewModel
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }
}

#if DEBUG
struct CuisineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample cuisine for preview
        let sampleDishes = [
            Dish(id: "sample1", name: "Sample Dish 1", image: "photo", price: 250, rating: 4.5, cuisineType: "Sample"),
            Dish(id: "sample2", name: "Sample Dish 2", image: "photo", price: 350, rating: 4.2, cuisineType: "Sample")
        ]
        let sampleCuisine = Cuisine(id: "1", name: "Sample Cuisine", image: "photo", dishes: sampleDishes)
        
        NavigationView {
            CuisineDetailView(
                cuisine: sampleCuisine,
                homeViewModel: HomeViewModel()
            )
        }
    }
}
#endif 