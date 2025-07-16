import Foundation
import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var cuisines: [Cuisine] = []
    @Published var topDishes: [Dish] = []
    @Published var selectedLanguage: Language = .english
    @Published var cart = Cart()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var orderHistory: [OrderRecord] = [] // For Order History (loaded from UserDefaults)
    @Published var latestTransactionId: String? = nil
    @Published var orderPlacementError: String? = nil
    
    private let apiService = APIService()
    private var cancellables = Set<AnyCancellable>()
    private let userDefaultsOrderHistoryKey = "userOrderHistory"
    
    init() {
        // Initialize with empty arrays
        cuisines = []
        topDishes = []
        
        loadOrderHistory() // Load history from UserDefaults into self.orderHistory
        
        // Fetch data from API
        fetchCuisinesAndItems()
    }
    
    // MARK: - API Methods
    
    func fetchCuisinesAndItems() {
        isLoading = true
        errorMessage = nil
        
        apiService.fetchAllCuisines { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let cuisineResponses):
                    // Filter out duplicates by cuisineId
                    let uniqueCuisineResponses = self?.removeDuplicateCuisines(cuisineResponses) ?? []
                    
                    // Map API response to app models
                    let cuisines = uniqueCuisineResponses.map { Cuisine.fromAPIResponse($0) }
                    self?.cuisines = cuisines
                    
                    // Extract top dishes (for example, dishes with highest ratings)
                    var allDishes: [Dish] = []
                    for cuisine in cuisines {
                        allDishes.append(contentsOf: cuisine.dishes)
                    }
                    
                    // Sort by rating and take top 3
                    self?.topDishes = allDishes.sorted(by: { $0.rating > $1.rating }).prefix(3).map { $0 }
                    
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                    print("Error fetching data: \(error)")
                }
            }
        }
    }
    
    // Helper method to remove duplicate cuisines
    private func removeDuplicateCuisines(_ cuisines: [CuisineResponse]) -> [CuisineResponse] {
        var uniqueCuisines: [CuisineResponse] = []
        var seenIds = Set<String>()
        
        for cuisine in cuisines {
            if !seenIds.contains(cuisine.cuisineId) {
                uniqueCuisines.append(cuisine)
                seenIds.insert(cuisine.cuisineId)
            }
        }
        
        return uniqueCuisines
    }
    
    // Method to get a dish by ID
    func getDishById(id: String) -> Dish? {
        // First check in top dishes
        if let dish = topDishes.first(where: { $0.id == id }) {
            return dish
        }
        
        // Then check in all cuisines
        for cuisine in cuisines {
            if let dish = cuisine.dishes.first(where: { $0.id == id }) {
                return dish
            }
        }
        
        return nil
    }
    
    // Method to fetch item details by ID from API
    func fetchItemDetails(itemId: String, completion: @escaping (Result<Dish, APIError>) -> Void) {
        isLoading = true
        
        apiService.fetchItemDetails(itemId: itemId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    let dish = response.toDish()
                    completion(.success(dish))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Cart Methods
    
    // Method to add a dish to the cart
    func addToCart(_ dish: Dish) {
        cart.addDish(dish)
    }
    
    // Method to remove a dish from the cart
    func removeFromCart(_ dish: Dish) {
        cart.removeDish(dish)
    }
    
    // Method to update the quantity of a dish in the cart
    func updateQuantity(for dish: Dish, quantity: Int) {
        cart.updateQuantity(for: dish, quantity: quantity)
    }
    
    // MARK: - Order Placement and History
    
    func placeOrder() {
        guard !cart.items.isEmpty else {
            DispatchQueue.main.async {
                self.orderPlacementError = "Your cart is empty."
                self.isLoading = false
            }
            return
        }

        DispatchQueue.main.async {
            self.isLoading = true
            self.orderPlacementError = nil
            self.latestTransactionId = nil
        }

        // 1. Prepare PaymentItemData
        var paymentItems: [PaymentItemData] = []
        for cartItem in cart.items {
            guard let cuisineModel = cuisines.first(where: { $0.name == cartItem.dish.cuisineType }),
                  let cuisineIdInt = Int(cuisineModel.id) else {
                DispatchQueue.main.async {
                    self.orderPlacementError = "Could not convert cuisine ID '\\(String(describing: self.cuisines.first(where: { $0.name == cartItem.dish.cuisineType })?.id))' to Int for item: \\(cartItem.dish.name)."
                    self.isLoading = false
                }
                return
            }
            
            guard let itemIdInt = Int(cartItem.dish.id) else {
                DispatchQueue.main.async {
                    self.orderPlacementError = "Could not convert item ID '\\(cartItem.dish.id)' to Int for item: \\(cartItem.dish.name)."
                    self.isLoading = false
                }
                return
            }
            
            let paymentItem = PaymentItemData(
                cuisine_id: cuisineIdInt,
                item_id: itemIdInt,
                item_price: Int(cartItem.dish.price.rounded()),
                item_quantity: cartItem.quantity
            )
            paymentItems.append(paymentItem)
        }

        let currentGrandTotal = cart.grandTotal
        var totalAmountString: String
        if floor(currentGrandTotal) == currentGrandTotal { // Check if it's a whole number
            totalAmountString = String(Int(currentGrandTotal))
        } else {
            totalAmountString = String(format: "%.2f", currentGrandTotal)
        }

        let totalItemsCount = cart.items.reduce(0) { $0 + $1.quantity }
        
        let paymentRequest = MakePaymentRequest(
            total_amount: totalAmountString,
            total_items: totalItemsCount,
            data: paymentItems
        )

        // 3. Call API
        apiService.makePayment(requestPayload: paymentRequest) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let paymentResponse):
                    self.latestTransactionId = paymentResponse.txnRefNo
                    self.saveOrderToHistory(transactionId: paymentResponse.txnRefNo,
                                            items: self.cart.items, // Important: capture cart items *before* clearing
                                            grandTotal: self.cart.grandTotal)
                    // Cart clearing will be handled by the view after alert dismissal
                case .failure(let error):
                    if let apiError = error as? APIError {
                        switch apiError {
                        case .serverError(let msg):
                            self.orderPlacementError = "Order failed: \\(msg)"
                        default:
                            self.orderPlacementError = "Order failed: \\(error.localizedDescription)"
                        }
                    } else {
                        self.orderPlacementError = "Order failed: \\(error.localizedDescription)"
                    }
                }
            }
        }
    }

    private func saveOrderToHistory(transactionId: String, items: [CartItem], grandTotal: Double) {
        let newOrderRecord = OrderRecord(
            id: UUID().uuidString, // Generate a new UUID for the local order ID
            transactionId: transactionId, // Store the API's transaction ID separately
            items: items,
            grandTotal: grandTotal,
            date: Date()
        )
        
        var currentHistory = loadOrderHistoryInternal()
        currentHistory.insert(newOrderRecord, at: 0) // Add to the beginning
        
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(currentHistory)
            UserDefaults.standard.set(encodedData, forKey: userDefaultsOrderHistoryKey)
            DispatchQueue.main.async {
                self.orderHistory = currentHistory // Update published property
            }
        } catch {
            print("Failed to save order history: \\(error)")
            // Optionally set an error message for the UI
        }
    }

    func loadOrderHistory() {
        self.orderHistory = loadOrderHistoryInternal()
    }
    
    private func loadOrderHistoryInternal() -> [OrderRecord] {
        guard let savedData = UserDefaults.standard.data(forKey: userDefaultsOrderHistoryKey) else {
            return []
        }
        do {
            let decoder = JSONDecoder()
            let decodedHistory = try decoder.decode([OrderRecord].self, from: savedData)
            return decodedHistory
        } catch {
            print("Failed to load order history: \\(error)")
            return []
        }
    }
    
    // MARK: - Payment Methods
    
    // Method to make payment for the cart items
    func makePayment(completion: @escaping (Result<String, Error>) -> Void) {
        isLoading = true
        
        // Simulate payment success (in a real app, this would call an API)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.isLoading = false
            
            // Generate a transaction ID
            let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let randomString = String((0..<10).map { _ in letters.randomElement()! })
            let transactionId = "TXN\(randomString)"
            
            // Create an order from the cart items
            let order = Order(
                items: self.cart.items.map { $0.dish },
                orderDate: Date(),
                totalAmount: self.cart.grandTotal,
                orderStatus: .completed,
                transactionId: transactionId
            )
            
            // Add the order to the order manager
            OrderManager.shared.addOrder(order)
            
            // Clear the cart
            self.cart.clearCart()
            
            // Return the transaction ID
            completion(.success(transactionId))
        }
    }
    
    // Method to toggle language between English and Hindi
    func toggleLanguage() {
        selectedLanguage = selectedLanguage == .english ? .hindi : .english
    }
} 