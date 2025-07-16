import Foundation

struct Dish: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let image: String
    let price: Double
    let rating: Double
    var quantity: Int = 0
    let cuisineType: String
    
    init(id: String = UUID().uuidString, name: String, image: String, price: Double, rating: Double, quantity: Int = 0, cuisineType: String) {
        self.id = id
        self.name = name
        self.image = image
        self.price = price
        self.rating = rating
        self.quantity = quantity
        self.cuisineType = cuisineType
    }
} 