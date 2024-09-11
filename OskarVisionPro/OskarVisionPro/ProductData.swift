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

// Categories variable to store fetched categories
var categories: [Category] = []

// Function to fetch categories from the API
func fetchCategories(completion: @escaping () -> Void) {
    print("Starting fetchCategories function")
    guard let url = URL(string: "https://5e67-213-61-226-202.ngrok-free.app/category-trees") else {
        print("Invalid URL: https://5e67-213-61-226-202.ngrok-free.app/category-trees")
        return
    }
    
    print("Making network request to: \(url)")
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching categories: \(error)")
            return
        }
        
        guard let data = data else {
            print("No data received from the server")
            return
        }
        
        print("Received data of size: \(data.count) bytes")
        
         do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("JSON structure: \(json.keys)")
                if let dataArray = json["data"] as? [[String: Any]] {
                    print("Number of categories in dataArray: \(dataArray.count)")
                    
                    func parseCategories(_ categoryNodes: [[String: Any]]) -> [Category] {
                        var categories: [Category] = []
                        
                        for node in categoryNodes {
                            if let name = node["name"] as? String {
                                let category = Category(name: name)
                                categories.append(category)
                                
                                if let children = node["children"] as? [[String: Any]] {
                                    let subcategories = parseCategories(children)
                                    categories.append(contentsOf: subcategories)
                                }
                            }
                        }
                        
                        return categories
                    }
                    
                    let fetchedCategories = dataArray.compactMap { categoryData -> [Category] in
                        if let attributes = categoryData["attributes"] as? [String: Any],
                           let categoryNodesStorage = attributes["categoryNodesStorage"] as? [[String: Any]] {
                            return parseCategories(categoryNodesStorage)
                        }
                        print("Failed to parse categories")
                        return []
                    }.flatMap { $0 }
                    
                    DispatchQueue.main.async {
                        categories = fetchedCategories
                        print("Updated categories. Total count: \(categories.count)")
                        completion()
                    }
                } else {
                    print("Failed to extract dataArray from JSON")
                }
            } else {
                print("Failed to parse JSON")
            }
        } catch {
            print("Error parsing JSON: \(error)")
        }
    }.resume()
    print("Network request initiated")
}

// Mock products
var products = [
    Product(name: "Laptop", price: 1299.99, imageURL: "https://images.unsplash.com/photo-1496181133206-80ce9b88a853", description: "A powerful laptop for all your computing needs."),
    Product(name: "Smartphone", price: 999.99, imageURL: "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9", description: "The latest smartphone with cutting-edge features."),
    Product(name: "Headphones", price: 199.99, imageURL: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e", description: "High-quality headphones for immersive audio experience.")
]

// Current Selected 3D Model as String URL
var selected3DModelURL: String = ""

// Function to load products based on category selection
func loadProducts(for category: String) {
    print("Loading products for category: \(category)")
    
    // fetch products from API
    fetchProducts(for: category) { fetchedProducts in
        products = fetchedProducts
    }
}

// Function to fetch products from a specific category by name
func fetchProducts(for categoryName: String, completion: @escaping ([Product]) -> Void) {
    guard let url = URL(string: "https://5e67-213-61-226-202.ngrok-free.app/catalog-search?q=\(categoryName)") else {
        print("Invalid URL")
        completion([])
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error fetching products: \(error)")
            completion([])
            return
        }
        
        guard let data = data else {
            print("No data received from the server")
            completion([])
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataArray = json["data"] as? [[String: Any]],
               let attributes = dataArray.first?["attributes"] as? [String: Any],
               let abstractProducts = attributes["abstractProducts"] as? [[String: Any]] {
                let fetchedProducts = abstractProducts.compactMap { productData -> Product? in
                    guard let abstractSku = productData["abstractSku"] as? String,
                          let abstractName = productData["abstractName"] as? String,
                          let price = productData["price"] as? Double,
                          let prices = productData["prices"] as? [[String: Any]],
                          let defaultPrice = prices.first(where: { $0["priceTypeName"] as? String == "DEFAULT" }),
                          let currency = defaultPrice["currency"] as? [String: Any],
                          let currencySymbol = currency["symbol"] as? String else {
                        return nil
                    }
                    
                    let imageURL = (productData["images"] as? [[String: Any]])?.first?["externalUrlLarge"] as? String ?? ""
                    let description = "No description available" // As there's no description in the provided data
                    
                    let formattedPrice = String(format: "%.2f", price / 100) // Convert cents to dollars/euros
                    let displayPrice = "\(currencySymbol)\(formattedPrice)"
                    
                    return Product(name: abstractName, price: price / 100, imageURL: imageURL, description: description)
                }
                
                DispatchQueue.main.async {
                    completion(fetchedProducts)
                }
            } else {
                print("Failed to parse JSON")
                completion([])
            }
        } catch {
            print("Error parsing JSON: \(error)")
            completion([])
        }
    }.resume()
}
