import Foundation

struct Cuisine: Identifiable, Hashable {
    let id: String
    let name: String
    let image: String
    let dishes: [Dish]
    
    init(id: String = UUID().uuidString, name: String, image: String, dishes: [Dish]) {
        self.id = id
        self.name = name
        self.image = image
        self.dishes = dishes
    }
    
    // Convert from API response to app model
    static func fromAPIResponse(_ cuisineResponse: CuisineResponse) -> Cuisine {
        let dishes = cuisineResponse.items.map { item in
            item.toDish(cuisineType: cuisineResponse.cuisineName)
        }
        
        return Cuisine(
            id: cuisineResponse.cuisineId,
            name: cuisineResponse.cuisineName,
            image: cuisineResponse.cuisineImageUrl,
            dishes: dishes
        )
    }
    
    // Empty array for initial state before API data loads
    static let sampleData: [Cuisine] = []
} 