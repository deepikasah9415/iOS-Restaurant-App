import Foundation

// MARK: - API Response Models

// Filter API Response structure - doesn't have pagination fields
struct FilterAPIResponse: Codable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    let cuisines: [CuisineResponse]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
        case cuisines
    }
}

// Common response structure for paginated endpoints
struct APIResponse: Codable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    let page: Int
    let count: Int
    let totalPages: Int
    let totalItems: Int
    let cuisines: [CuisineResponse]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
        case page
        case count
        case totalPages = "total_pages"
        case totalItems = "total_items"
        case cuisines
    }
}

// Cuisine response structure
struct CuisineResponse: Codable, Identifiable {
    let cuisineId: String
    let cuisineName: String
    let cuisineImageUrl: String
    let items: [ItemResponse]
    
    // Computed property to make it compatible with the Identifiable protocol
    var id: String { cuisineId }
    
    enum CodingKeys: String, CodingKey {
        case cuisineId = "cuisine_id"
        case cuisineName = "cuisine_name"
        case cuisineImageUrl = "cuisine_image_url"
        case items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle cuisine_id which can be either String or Int in the API
        if let cuisineIdString = try? container.decode(String.self, forKey: .cuisineId) {
            // If it's a string, use it directly
            cuisineId = cuisineIdString
        } else if let cuisineIdInt = try? container.decode(Int.self, forKey: .cuisineId) {
            // If it's an integer, convert to string
            cuisineId = String(cuisineIdInt)
        } else {
            // If neither works, throw an error
            throw DecodingError.dataCorruptedError(forKey: .cuisineId, in: container, debugDescription: "Expected cuisine_id to be String or Int")
        }
        
        // Decode the rest of the properties normally
        cuisineName = try container.decode(String.self, forKey: .cuisineName)
        cuisineImageUrl = try container.decode(String.self, forKey: .cuisineImageUrl)
        items = try container.decode([ItemResponse].self, forKey: .items)
    }
}

// Item (dish) response structure
struct ItemResponse: Codable, Identifiable {
    let id: String
    let name: String
    let imageUrl: String
    let price: String
    let rating: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case imageUrl = "image_url"
        case price
        case rating
    }
    
    // Custom initializer to handle both String and Int ids
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle id which can be either String or Int in the API
        if let idString = try? container.decode(String.self, forKey: .id) {
            // If it's a string, use it directly
            id = idString
        } else if let idInt = try? container.decode(Int.self, forKey: .id) {
            // If it's an integer, convert to string
            id = String(idInt)
        } else {
            // If neither works, throw an error
            throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Expected id to be String or Int")
        }
        
        // Handle remaining fields
        name = try container.decode(String.self, forKey: .name)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        
        // Handle price which might be String or various number types
        if let priceString = try? container.decode(String.self, forKey: .price) {
            price = priceString
        } else if let priceInt = try? container.decode(Int.self, forKey: .price) {
            price = String(priceInt)
        } else if let priceDouble = try? container.decode(Double.self, forKey: .price) {
            price = String(priceDouble)
        } else {
            price = "0"
        }
        
        // Handle rating which might be String or various number types
        if let ratingString = try? container.decode(String.self, forKey: .rating) {
            rating = ratingString
        } else if let ratingInt = try? container.decode(Int.self, forKey: .rating) {
            rating = String(ratingInt)
        } else if let ratingDouble = try? container.decode(Double.self, forKey: .rating) {
            rating = String(ratingDouble)
        } else {
            rating = "0"
        }
    }
    
    // Helper method to convert to the app's Dish model
    func toDish(cuisineType: String) -> Dish {
        return Dish(
            id: id,
            name: name,
            image: imageUrl,
            price: Double(price) ?? 0.0,
            rating: Double(rating) ?? 0.0,
            cuisineType: cuisineType
        )
    }
}

// Item details response
struct ItemDetailsResponse: Codable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    let cuisineId: String
    let cuisineName: String
    let cuisineImageUrl: String
    let itemId: String
    let itemName: String
    let itemPrice: String
    let itemRating: String
    let itemImageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
        case cuisineId = "cuisine_id"
        case cuisineName = "cuisine_name"
        case cuisineImageUrl = "cuisine_image_url"
        case itemId = "item_id"
        case itemName = "item_name"
        case itemPrice = "item_price"
        case itemRating = "item_rating"
        case itemImageUrl = "item_image_url"
    }
    
    // Custom initializer to handle both String and Int values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Regular fields
        responseCode = try container.decode(Int.self, forKey: .responseCode)
        outcomeCode = try container.decode(Int.self, forKey: .outcomeCode)
        responseMessage = try container.decode(String.self, forKey: .responseMessage)
        cuisineName = try container.decode(String.self, forKey: .cuisineName)
        cuisineImageUrl = try container.decode(String.self, forKey: .cuisineImageUrl)
        itemName = try container.decode(String.self, forKey: .itemName)
        itemImageUrl = try container.decode(String.self, forKey: .itemImageUrl)
        
        // Handle cuisine_id which can be either String or Int
        if let cuisineIdString = try? container.decode(String.self, forKey: .cuisineId) {
            cuisineId = cuisineIdString
        } else if let cuisineIdInt = try? container.decode(Int.self, forKey: .cuisineId) {
            cuisineId = String(cuisineIdInt)
        } else {
            cuisineId = ""
        }
        
        // Handle item_id which can be either String or Int
        if let itemIdString = try? container.decode(String.self, forKey: .itemId) {
            itemId = itemIdString
        } else if let itemIdInt = try? container.decode(Int.self, forKey: .itemId) {
            itemId = String(itemIdInt)
        } else {
            itemId = ""
        }
        
        // Handle item_price which might be String or various number types
        if let priceString = try? container.decode(String.self, forKey: .itemPrice) {
            itemPrice = priceString
        } else if let priceInt = try? container.decode(Int.self, forKey: .itemPrice) {
            itemPrice = String(priceInt)
        } else if let priceDouble = try? container.decode(Double.self, forKey: .itemPrice) {
            itemPrice = String(priceDouble)
        } else {
            itemPrice = "0"
        }
        
        // Handle item_rating which might be String or various number types
        if let ratingString = try? container.decode(String.self, forKey: .itemRating) {
            itemRating = ratingString
        } else if let ratingInt = try? container.decode(Int.self, forKey: .itemRating) {
            itemRating = String(ratingInt)
        } else if let ratingDouble = try? container.decode(Double.self, forKey: .itemRating) {
            itemRating = String(ratingDouble)
        } else {
            itemRating = "0"
        }
    }
    
    // Helper method to convert to the app's Dish model
    func toDish() -> Dish {
        return Dish(
            id: itemId,
            name: itemName,
            image: itemImageUrl,
            price: Double(itemPrice) ?? 0.0,
            rating: Double(itemRating) ?? 0.0,
            cuisineType: cuisineName
        )
    }
}

// Payment response
struct PaymentResponse: Codable {
    let responseCode: Int
    let outcomeCode: Int
    let responseMessage: String
    let txnRefNo: String
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case outcomeCode = "outcome_code"
        case responseMessage = "response_message"
        case txnRefNo = "txn_ref_no"
    }
} 