//
//  ProductListView.swift
//  OskarVisionPro
//
//  Created by Phil Miletic on 11.09.24.
//

import SwiftUI

struct ProductListView: View {
    @Binding var selectedProduct: Product?
    @Binding var selectedCategory: Category?
    @State private var products: [Product] = []

    var body: some View {
        VStack {
            Text("Products")
                .font(.headline)
                .padding(.bottom, 10)
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(products) { product in
                        HStack {
                            AsyncImage(url: URL(string: product.imageURL)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(5)
                            } placeholder: {
                                ProgressView()
                            }
                            Text(product.name)
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "$%.2f", product.price))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(10)
                        .background(selectedProduct?.id == product.id ? Color.white.opacity(0.2) : Color.clear)
                        .contentShape(Rectangle())
                        .hoverEffect(.lift)
                        .onTapGesture {
                            selectedProduct = product
                            fetchProduct(sku: product.sku)
                        }
                    }
                }
            }
        }
        .frame(width: 300)
        .padding(.top, 20)
        .glassBackgroundEffect()
        .onChange(of: selectedCategory) { newCategory in
            if let category = newCategory {
                fetchProducts(for: category.name)
            }
        }
    }
    
    private func fetchProducts(for categoryName: String) {
        print("Starting fetchProducts for category: \(categoryName)")
        guard let url = URL(string: "\(urlPrefix)/catalog-search?q=\(categoryName)") else {
            print("Invalid URL for category: \(categoryName)")
            return
        }
        
        print("Initiating network request to URL: \(url.absoluteString)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching products for \(categoryName): \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received from the server for \(categoryName)")
                return
            }
            
            print("Received \(data.count) bytes of data for \(categoryName)")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Successfully parsed JSON for \(categoryName)")
                    if let dataArray = json["data"] as? [[String: Any]] {
                        print("Found data array with \(dataArray.count) items")
                        if let attributes = dataArray.first?["attributes"] as? [String: Any] {
                            print("Found attributes in the first data item")
                            if let abstractProducts = attributes["abstractProducts"] as? [[String: Any]] {
                                print("Found abstractProducts with \(abstractProducts.count) items")
                                let fetchedProducts = abstractProducts.compactMap { productData -> Product? in
                                    guard let abstractSku = productData["abstractSku"] as? String,
                                          let abstractName = productData["abstractName"] as? String,
                                          let price = productData["price"] as? Double,
                                          let prices = productData["prices"] as? [[String: Any]],
                                          let defaultPrice = prices.first(where: { $0["priceTypeName"] as? String == "DEFAULT" }),
                                          let currency = defaultPrice["currency"] as? [String: Any],
                                          let currencySymbol = currency["symbol"] as? String else {
                                        print("Failed to parse product data: \(productData)")
                                        return nil
                                    }
                                    
                                    let imageURL = (productData["images"] as? [[String: Any]])?.first?["externalUrlLarge"] as? String ?? ""
                                    let description = "No description available" // As there's no description in the provided data

                                    // replace imageURL "http://yves.de.spryker.local" with "https://6c27-213-61-226-202.ngrok-free.app"
                                    let newImageUrl = imageURL.replacingOccurrences(of: "http://yves.de.spryker.local", with: "https://6c27-213-61-226-202.ngrok-free.app")

                                    let formattedPrice = String(format: "%.2f", price / 100) // Convert cents to dollars/euros
                                    let displayPrice = "\(currencySymbol)\(formattedPrice)"
                                    
                                    print("Successfully parsed product: \(abstractName) with price \(displayPrice)")
                                    return Product(name: abstractName, price: price / 100, imageURL: newImageUrl, description: description, sku: abstractSku, productModel: nil)
                                }
                                
                                print("Parsed \(fetchedProducts.count) products for \(categoryName)")
                                DispatchQueue.main.async {
                                    self.products = fetchedProducts
                                    print("Updated products with \(fetchedProducts.count) items")
                                }
                            } else {
                                print("Failed to find abstractProducts in attributes")
                            }
                        } else {
                            print("Failed to find attributes in the first data item")
                        }
                    } else {
                        print("Failed to find data array in JSON")
                    }
                } else {
                    print("Failed to parse JSON for \(categoryName)")
                }
            } catch {
                print("Error parsing JSON for \(categoryName): \(error)")
            }
        }.resume()
        print("Network request initiated for \(categoryName)")
    }

    private func fetchProduct(sku: String) {
    print("Starting fetchProduct for SKU: \(sku)")
    guard let url = URL(string: "\(urlPrefix)/abstract-products/\(sku)") else {
        print("Invalid URL for SKU: \(sku)")
        return
    }
    
    print("Initiating network request to URL: \(url.absoluteString)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching product for \(sku): \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received from the server for \(sku)")
                return
            }
            
            print("Received \(data.count) bytes of data for \(sku)")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let productData = json["data"] as? [String: Any],
                let attributes = productData["attributes"] as? [String: Any] {
                    print("Successfully parsed JSON for \(sku)")
                    
                    let abstractSku = attributes["sku"] as? String ?? ""
                    let abstractName = attributes["name"] as? String ?? ""
                    let description = attributes["description"] as? String ?? "No description available"
                    let imageURL = attributes["imageURL"] as? String ?? ""
                    let price = attributes["price"] as? Double ?? 0.0
                    let productModel = attributes["productModel"] as? String ?? ""

                    // replace productModel "http://yves.de.spryker.local" with "https://6c27-213-61-226-202.ngrok-free.app"
                    let newProductModel = productModel.replacingOccurrences(of: "http://yves.de.spryker.local", with: "https://6c27-213-61-226-202.ngrok-free.app")

                    // same for image urls
                    let newImageUrl = imageURL.replacingOccurrences(of: "http://yves.de.spryker.local", with: "https://6c27-213-61-226-202.ngrok-free.app")

                    print("Successfully parsed product: \(abstractName) with price \(price)")
                    let product = Product(name: abstractName, price: price, imageURL: newImageUrl, description: description, sku: abstractSku, productModel: newProductModel)

                    DispatchQueue.main.async {
                        self.selectedProduct = product
                        print("Updated selected product with new product model \(newProductModel)")
                    }
                } else {
                    print("Failed to parse JSON for \(sku)")
                }
            } catch {
                print("Error parsing JSON for \(sku): \(error)")
            }
        }.resume()
        print("Network request initiated for \(sku)")
    }
}
