import Foundation

enum Language: String, CaseIterable, Identifiable {
    case english = "English"
    case hindi = "हिंदी"
    
    var id: String { self.rawValue }
    
    // Home Screen Translations
    var homeTitle: String {
        switch self {
        case .english: return "Home"
        case .hindi: return "होम"
        }
    }
    
    var topDishesTitle: String {
        switch self {
        case .english: return "Top Dishes"
        case .hindi: return "टॉप डिशेज़"
        }
    }
    
    var cartButtonTitle: String {
        switch self {
        case .english: return "Cart"
        case .hindi: return "कार्ट"
        }
    }
    
    var addToCartText: String {
        switch self {
        case .english: return "Add"
        case .hindi: return "जोड़ें"
        }
    }
    
    // Cuisine Screen Translations
    var backButtonTitle: String {
        switch self {
        case .english: return "Back"
        case .hindi: return "वापस"
        }
    }
    
    // Cart Screen Translations
    var cartTitle: String {
        switch self {
        case .english: return "Cart"
        case .hindi: return "कार्ट"
        }
    }
    
    var totalText: String {
        switch self {
        case .english: return "Total"
        case .hindi: return "कुल"
        }
    }
    
    var cgstText: String {
        switch self {
        case .english: return "CGST (2.5%)"
        case .hindi: return "CGST (2.5%)"
        }
    }
    
    var sgstText: String {
        switch self {
        case .english: return "SGST (2.5%)"
        case .hindi: return "SGST (2.5%)"
        }
    }
    
    var grandTotalText: String {
        switch self {
        case .english: return "Grand Total"
        case .hindi: return "कुल योग"
        }
    }
    
    var placeOrderText: String {
        switch self {
        case .english: return "Place Order"
        case .hindi: return "ऑर्डर करें"
        }
    }
    
    var emptyCartText: String {
        switch self {
        case .english: return "Your cart is empty"
        case .hindi: return "आपका कार्ट खाली है"
        }
    }
    
    var previousOrdersTitle: String {
        switch self {
        case .english: return "Previous Orders"
        case .hindi: return "पिछले ऑर्डर"
        }
    }
} 