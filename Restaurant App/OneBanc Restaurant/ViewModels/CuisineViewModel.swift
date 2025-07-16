import Foundation
import SwiftUI
import Combine

class CuisineViewModel: ObservableObject {
    @Published var selectedCuisine: Cuisine
    @Published var dishes: [Dish] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()
    
    init(cuisine: Cuisine) {
        self.selectedCuisine = cuisine
        self.dishes = cuisine.dishes
        
        // Print debug info
        print("CuisineViewModel initialized with:")
        print("- Cuisine ID: \(cuisine.id)")
        print("- Cuisine Name: \(cuisine.name)")
        print("- Number of dishes: \(cuisine.dishes.count)")
    }
    
    // Method to get dishes for a selected cuisine
    func getDishes() -> [Dish] {
        return dishes
    }
    
    // Method to fetch dishes by cuisine type using filter
    func fetchDishesByCuisineType() {
        isLoading = true
        errorMessage = nil
        
        print("Fetching dishes for cuisine: \(selectedCuisine.name)")
        
        // First approach: Use the dishes already attached to the cuisine (from initial load)
        if !selectedCuisine.dishes.isEmpty {
            print("Using pre-loaded dishes for \(selectedCuisine.name)")
            dishes = selectedCuisine.dishes
        }
        
        // Second approach: Use the API's filter functionality to get dishes for this cuisine type
        apiService.fetchItemsByFilter(cuisineType: [selectedCuisine.name]) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    print("Filter API Success: Received \(response.cuisines.count) cuisines")
                    
                    // Print all received cuisines for debugging
                    print("Available cuisines in response:")
                    for cuisine in response.cuisines {
                        print("- \(cuisine.cuisineName) (ID: \(cuisine.cuisineId)) with \(cuisine.items.count) dishes")
                    }
                    
                    // First, try exact match (case-sensitive)
                    var matchingCuisine = response.cuisines.first(where: { $0.cuisineName == self.selectedCuisine.name })
                    
                    // If no match, try case-insensitive match
                    if matchingCuisine == nil {
                        matchingCuisine = response.cuisines.first(where: { 
                            $0.cuisineName.lowercased() == self.selectedCuisine.name.lowercased() 
                        })
                    }
                    
                    // If still no match, try contains
                    if matchingCuisine == nil {
                        matchingCuisine = response.cuisines.first(where: { 
                            $0.cuisineName.lowercased().contains(self.selectedCuisine.name.lowercased()) ||
                            self.selectedCuisine.name.lowercased().contains($0.cuisineName.lowercased())
                        })
                    }
                    
                    // If still no match, try matching by ID
                    if matchingCuisine == nil {
                        matchingCuisine = response.cuisines.first(where: { $0.cuisineId == self.selectedCuisine.id })
                    }
                    
                    if let matchingCuisine = matchingCuisine {
                        print("Found matching cuisine: \(matchingCuisine.cuisineName) with \(matchingCuisine.items.count) dishes")
                        
                        // Check if the API returned any dishes
                        if !matchingCuisine.items.isEmpty {
                            // Convert API dishes to our Dish model
                            self.dishes = matchingCuisine.items.map { item in
                                // Check if price or rating is missing
                                let price = Double(item.price) ?? 0
                                let rating = Double(item.rating) ?? 0
                                
                                // If price or rating is missing, we'll still create the dish but log it
                                if price == 0 || rating == 0 {
                                    print("⚠️ Warning: Missing price (\(price)) or rating (\(rating)) for dish: \(item.name)")
                                }
                                
                                return Dish(
                                    id: item.id,
                                    name: item.name,
                                    image: item.imageUrl,
                                    price: price,
                                    rating: rating,
                                    cuisineType: self.selectedCuisine.name
                                )
                            }
                            print("Successfully mapped \(self.dishes.count) dishes from API")

                            // Fetch complete details for each dish if price or rating is missing
                            if !self.dishes.isEmpty {
                                self.fetchMissingDishDetails()
                            }
                        } else {
                            // If no dishes were returned but we have pre-loaded dishes, keep those
                            if !self.dishes.isEmpty {
                                print("API returned no dishes, keeping \(self.dishes.count) pre-loaded dishes")
                            } else {
                                print("No dishes found for \(matchingCuisine.cuisineName)")
                                self.errorMessage = "No dishes available for \(self.selectedCuisine.name) cuisine"
                            }
                        }
                    } else {
                        print("No matching cuisine found in response for: \(self.selectedCuisine.name)")
                        
                        // Keep the pre-loaded dishes if we have them
                        if self.dishes.isEmpty {
                            self.errorMessage = "Could not find details for \(self.selectedCuisine.name) cuisine"
                        } else {
                            print("Using \(self.dishes.count) pre-loaded dishes for \(self.selectedCuisine.name)")
                        }
                    }
                    
                case .failure(let error):
                    self.errorMessage = "Failed to fetch dishes: \(error.localizedDescription)"
                    print("Error fetching dishes by cuisine: \(error)")
                    
                    // Keep the pre-loaded dishes if we have them
                    if self.dishes.isEmpty {
                        self.errorMessage = "Could not load dishes for \(self.selectedCuisine.name) cuisine"
                    } else {
                        print("Using \(self.dishes.count) pre-loaded dishes despite API error")
                    }
                }
            }
        }
    }
    
    // Method to fetch dish details by ID
    func fetchDishDetails(itemId: String, completion: @escaping (Result<Dish, APIError>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        apiService.fetchItemDetails(itemId: itemId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    let dish = response.toDish()
                    completion(.success(dish))
                    
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch dish details: \(error.localizedDescription)"
                    print("Error fetching dish details: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Method to add a dish to the cart (will be called from the parent view model)
    func addToCart(_ dish: Dish, homeViewModel: HomeViewModel) {
        homeViewModel.addToCart(dish)
    }
    
    // Method to remove a dish from the cart (will be called from the parent view model)
    func removeFromCart(_ dish: Dish, homeViewModel: HomeViewModel) {
        homeViewModel.removeFromCart(dish)
    }
    
    // Method to fetch details for dishes that may be missing price or rating
    private func fetchMissingDishDetails() {
        print("Fetching detailed information for dishes...")
        
        // Create a group to handle multiple async requests
        let group = DispatchGroup()
        
        // For each dish that's missing price or rating, fetch complete details
        for (index, dish) in dishes.enumerated() {
            if dish.price == 0 || dish.rating == 0 {
                group.enter()
                
                print("Fetching details for dish: \(dish.name) (ID: \(dish.id))")
                fetchDishDetails(itemId: dish.id) { [weak self] result in
                    defer { group.leave() }
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let updatedDish):
                        // Update the dish with complete details
                        print("✅ Successfully fetched details for \(dish.name): Price: \(updatedDish.price), Rating: \(updatedDish.rating)")
                        
                        // Update the dish at the specific index
                        if index < self.dishes.count {
                            DispatchQueue.main.async {
                                // Create a new dish with updated price and rating but preserve other properties
                                let updatedDishWithQuantity = Dish(
                                    id: dish.id,
                                    name: dish.name,
                                    image: dish.image,
                                    price: updatedDish.price,
                                    rating: updatedDish.rating,
                                    quantity: dish.quantity,
                                    cuisineType: dish.cuisineType
                                )
                                
                                // Replace the dish at the index
                                self.dishes[index] = updatedDishWithQuantity
                            }
                        }
                        
                    case .failure(let error):
                        print("❌ Failed to fetch details for \(dish.name): \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // When all requests are done, update the UI
        group.notify(queue: .main) {
            print("✅ Finished fetching all missing dish details")
        }
    }
} 