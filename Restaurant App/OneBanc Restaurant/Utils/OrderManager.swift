import Foundation
import Combine

// A utility class to manage order persistence
class OrderManager {
    static let shared = OrderManager()
    
    private let ordersKey = "saved_orders"
    private var cancellables = Set<AnyCancellable>()
    
    @Published var savedOrders: [Order] = []
    
    private init() {
        loadOrders()
    }
    
    // Add a new order to persistent storage
    func addOrder(_ order: Order) {
        savedOrders.append(order)
        persistOrders()
    }
    
    // Load orders from UserDefaults
    private func loadOrders() {
        guard let data = UserDefaults.standard.data(forKey: ordersKey) else {
            savedOrders = []
            return
        }
        
        do {
            let decoder = JSONDecoder()
            savedOrders = try decoder.decode([Order].self, from: data)
        } catch {
            print("Error loading orders: \(error)")
            savedOrders = []
        }
    }
    
    // Persist orders to UserDefaults
    private func persistOrders() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(savedOrders)
            UserDefaults.standard.set(data, forKey: ordersKey)
        } catch {
            print("Error saving orders: \(error)")
        }
    }
    
    // Clear all saved orders (for testing)
    func clearAllOrders() {
        savedOrders = []
        UserDefaults.standard.removeObject(forKey: ordersKey)
    }
}
