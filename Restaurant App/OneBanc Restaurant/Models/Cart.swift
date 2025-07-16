import Foundation

// Structure to represent an item in the cart
struct CartItem: Identifiable, Codable {
    let id: String
    let dish: Dish
    var quantity: Int
    
    init(dish: Dish, quantity: Int = 1) {
        self.id = dish.id // This is correct now because dish.id is a String
        self.dish = dish
        self.quantity = quantity
    }
}

struct Cart: Identifiable {
    let id = UUID()
    var items: [CartItem] = []
    
    var totalPrice: Double {
        items.reduce(0) { total, item in
            total + (item.dish.price * Double(item.quantity))
        }
    }
    
    var cgst: Double {
        return totalPrice * 0.025
    }
    
    var sgst: Double {
        return totalPrice * 0.025
    }
    
    var grandTotal: Double {
        return totalPrice + cgst + sgst
    }
    
    mutating func addDish(_ dish: Dish) {
        if let index = items.firstIndex(where: { $0.dish.id == dish.id }) {
            var item = items[index]
            item.quantity += 1
            items[index] = item
        } else {
            let newItem = CartItem(dish: dish, quantity: 1)
            items.append(newItem)
        }
    }
    
    mutating func removeDish(_ dish: Dish) {
        if let index = items.firstIndex(where: { $0.dish.id == dish.id }) {
            var item = items[index]
            if item.quantity > 1 {
                item.quantity -= 1
                items[index] = item
            } else {
                items.remove(at: index)
            }
        }
    }
    
    mutating func updateQuantity(for dish: Dish, quantity: Int) {
        if let index = items.firstIndex(where: { $0.dish.id == dish.id }) {
            var item = items[index]
            item.quantity = max(0, quantity)
            
            if item.quantity == 0 {
                items.remove(at: index)
            } else {
                items[index] = item
            }
        }
    }
    
    mutating func clearCart() {
        items.removeAll()
    }
} 