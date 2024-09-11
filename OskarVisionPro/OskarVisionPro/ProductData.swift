import Foundation

// Define the Category model
struct Category: Identifiable, Equatable {
    let id = UUID()
    let name: String
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

// Define the Product model
struct Product: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let price: Double
    let imageURL: String
    let description: String
    let sku: String
    let productModel: String?
    
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.price == rhs.price &&
               lhs.imageURL == rhs.imageURL &&
               lhs.description == rhs.description &&
               lhs.sku == rhs.sku &&
               lhs.productModel == rhs.productModel
    }
}

// Categories variable to store fetched categories
var categories: [Category] = []

var urlPrefix: String = "https://6c27-213-61-226-202.ngrok-free.app"

// Function to fetch categories from the API
func fetchCategories(completion: @escaping () -> Void) {
    print("Starting fetchCategories function")
    guard let url = URL(string: "\(urlPrefix)/category-trees") else {
        print("Invalid URL: \(urlPrefix)/category-trees")
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

// Current Selected 3D Model as String URL
var selected3DModelURL: String = ""
