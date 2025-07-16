import SwiftUI

struct AllTopDishesView: View {
    let dishes: [Dish]
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(dishes) { dish in
                    DishCard(dish: dish, viewModel: viewModel)
                        .frame(width: 340)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Top Dishes")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.pageBackground.ignoresSafeArea())
    }
}

#if DEBUG
struct AllTopDishesView_Previews: PreviewProvider {
    static var previews: some View {
        // Create sample dishes for preview
        let sampleDishes = [
            Dish(id: "sample1", name: "Sample Dish 1", image: "photo", price: 250, rating: 4.5, cuisineType: "Sample"),
            Dish(id: "sample2", name: "Sample Dish 2", image: "photo", price: 350, rating: 4.2, cuisineType: "Sample")
        ]
        AllTopDishesView(dishes: sampleDishes, viewModel: HomeViewModel())
    }
}
#endif 