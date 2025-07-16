import Foundation
import SwiftUI

struct Order: Identifiable, Codable {
    let id: String
    let items: [Dish]
    let orderDate: Date
    let totalAmount: Double
    let orderStatus: OrderStatus
    let transactionId: String?
    
    init(id: String = UUID().uuidString, items: [Dish], orderDate: Date, totalAmount: Double, orderStatus: OrderStatus, transactionId: String? = nil) {
        self.id = id
        self.items = items
        self.orderDate = orderDate
        self.totalAmount = totalAmount
        self.orderStatus = orderStatus
        self.transactionId = transactionId
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: orderDate)
    }
}

enum OrderStatus: String, Codable {
    case completed = "Completed"
    case inProgress = "In Progress"
    case cancelled = "Cancelled"
}

// Extension for UI-related properties that don't need to be Codable
extension OrderStatus {
    var color: Color {
        switch self {
        case .completed:
            return .green
        case .inProgress:
            return .orange
        case .cancelled:
            return .red
        }
    }
}

// Empty initial order data - will be populated from API
extension Order {
    static let sampleOrders: [Order] = []
} 