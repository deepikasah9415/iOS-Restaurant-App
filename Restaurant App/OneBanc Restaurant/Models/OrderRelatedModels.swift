import Foundation

// For storing order history
struct OrderRecord: Codable, Identifiable {
    let id: String // This will be the new, locally generated UUID orderId
    let transactionId: String // This is the TXN ID from the API
    let items: [CartItem] // Assumes CartItem is Codable
    let grandTotal: Double
    let date: Date

    // Optional: Custom init if you want to make id generation explicit here,
    // but it's often handled at the point of creation (e.g., in ViewModel).
    // init(id: String = UUID().uuidString, transactionId: String, items: [CartItem], grandTotal: Double, date: Date) {
    //     self.id = id
    //     self.transactionId = transactionId
    //     self.items = items
    //     self.grandTotal = grandTotal
    //     self.date = date
    // }
}

// For make_payment API request
struct MakePaymentRequest: Codable {
    let total_amount: String
    let total_items: Int
    let data: [PaymentItemData]

    // Define CodingKeys to ensure we use the correct keys, though they match property names here.
    // This also makes the custom encode function clearer.
    private enum CodingKeys: String, CodingKey {
        case total_amount
        case total_items
        case data
    }

    // Custom encoding to control key order
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Encode in the desired order
        try container.encode(self.total_amount, forKey: .total_amount)
        try container.encode(self.total_items, forKey: .total_items)
        try container.encode(self.data, forKey: .data)
    }
}

struct PaymentItemData: Codable {
    let cuisine_id: Int
    let item_id: Int
    let item_price: Int // Swift property name
    let item_quantity: Int

    // CodingKeys to define keys for custom encoding order.
    // Reverting item_price to use underscore as the JSON key.
    private enum CodingKeys: String, CodingKey {
        case cuisine_id
        case item_id
        case item_price // This will now map to "item_price"
        case item_quantity
    }

    // Custom encoding to control key order
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Encode in the desired order
        try container.encode(self.cuisine_id, forKey: .cuisine_id)
        try container.encode(self.item_id, forKey: .item_id)
        try container.encode(self.item_price, forKey: .item_price) // Will use "item_price" key
        try container.encode(self.item_quantity, forKey: .item_quantity)
    }
} 