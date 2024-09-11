import Foundation

// Define the Category model
struct Category: Identifiable {
    let id = UUID()
    let name: String
}

// Define the Product model
struct Product: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let imageURL: String
    let description: String
}

// Mock categories
let categories = [
    Category(name: "Electronics"),
    Category(name: "Fashion"),
    Category(name: "Home"),
    Category(name: "Books"),
    Category(name: "Toys")
]

// Mock products
var products = [
    Product(name: "Laptop", price: 1299.99, imageURL: "https://images.unsplash.com/photo-1496181133206-80ce9b88a853", description: "A powerful laptop for all your computing needs."),
    Product(name: "Smartphone", price: 999.99, imageURL: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9", description: "The latest smartphone with cutting-edge features."),
    Product(name: "Headphones", price: 199.99, imageURL: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e", description: "High-quality headphones for immersive audio experience.")
]

// Function to load products based on category selection
func loadProducts(for category: String) {
    // For now, we'll just update mock data. You would fetch data from API here.
    switch category {
    case "Electronics":
        products = [
            // ... existing products ...
        ]
    case "Fashion":
        products = [
            // Add fashion products...
        ]
    case "Home":
        products = [
            // Add home products...
        ]
    case "Books":
        products = [
            // Add book products...
        ]
    case "Toys":
        products = [
            // Add toy products...
        ]
    default:
        break
    }
}
