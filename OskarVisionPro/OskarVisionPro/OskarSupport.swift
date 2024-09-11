//
//  OskarSupport.swift
//  OskarVisionPro
//
//  Created by Phil Miletic on 11.09.24.
//

import SwiftUI

struct OskarSupport: View {
    @StateObject private var appState = AppState.shared
    @State private var isCheckingOut = false
    @State private var checkoutStatus: CheckoutStatus = .notStarted
    @State private var cartId: String?
    
    var body: some View {
        VStack {
            Text("Cart")
                .padding(.bottom)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Cart Summary")
                    .font(.headline)
                
                ForEach(appState.cartItems, id: \.product.id) { item in
                    HStack {
                        Text(item.product.name)
                        Spacer()
                        Text("\(item.quantity) x $\(item.product.price, specifier: "%.2f")")
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text("$\(cartTotal, specifier: "%.2f")")
                        .fontWeight(.bold)
                }
                
                Button(action: {
                    isCheckingOut = true
                    performCheckout()
                }) {
                    if isCheckingOut {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if checkoutStatus == .success {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Checkout")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                    }
                }
                .disabled(isCheckingOut || checkoutStatus == .success)
                .background(
                    Group {
                        if checkoutStatus == .success {
                            Color.green
                        } else if isCheckingOut {
                            Color.gray
                        } else {
                            Color.blue
                        }
                    }
                )
                .padding(.top)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(15)
        }
        .frame(width: 300, alignment: .leading)
        .padding()
        .glassBackgroundEffect()
    }
    
    private var cartTotal: Double {
        appState.cartItems.reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
    
    private func performCheckout() {
        checkoutStatus = .processing
        
        authenticateWithSprykerGlue { result in
            switch result {
            case .success(let token):
                createCartWithSpryker(token: token) { cartResult in
                    switch cartResult {
                    case .success(let cartId):
                        self.cartId = cartId
                        addItemsToCart(token: token, cartId: cartId)
                    case .failure(let error):
                        print("Cart creation failed: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.checkoutStatus = .notStarted
                            self.isCheckingOut = false
                        }
                    }
                }
            case .failure(let error):
                print("Authentication failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.checkoutStatus = .notStarted
                    self.isCheckingOut = false
                }
            }
        }
    }
    
    private func authenticateWithSprykerGlue(completion: @escaping (Result<String, Error>) -> Void) {
        print("Starting authentication with Spryker Glue")
        guard let url = URL(string: "\(urlPrefix)/access-tokens") else {
            print("Error: Invalid URL for authentication")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "data": [
                "type": "access-tokens",
                "attributes": [
                    "username": "spencor.hopkin@spryker.com",
                    "password": "change123"
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            print("Request body created successfully")
        } catch {
            print("Error creating request body: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        print("Sending authentication request to Spryker Glue")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error during authentication: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received from authentication request")
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            print("Received response from Spryker Glue, data size: \(data.count) bytes")
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataObject = json["data"] as? [String: Any],
                   let attributes = dataObject["attributes"] as? [String: Any],
                   let accessToken = attributes["accessToken"] as? String {
                    print("Successfully parsed access token")
                    completion(.success(accessToken))
                } else {
                    print("Failed to parse access token from response")
                    completion(.failure(NSError(domain: "Invalid response format", code: 0, userInfo: nil)))
                }
            } catch {
                print("Error parsing authentication response: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

    private func createCartWithSpryker(token: String, completion: @escaping (Result<String, Error>) -> Void) {
        print("Starting cart creation with Spryker")
        guard let url = URL(string: "\(urlPrefix)/carts") else {
            print("Error: Invalid URL for cart creation")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        // output token
        print("Token: \(token)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "data": [
                "type": "carts",
                "attributes": [
                    "priceMode": "GROSS_MODE",
                    "currency": "EUR",
                    "store": "DE",
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            print("Request body for cart creation created successfully")
        } catch {
            print("Error creating request body for cart creation: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error during cart creation: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received from cart creation request")
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            print("Received response from Spryker Glue for cart creation, data size: \(data.count) bytes")

            // output the json
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("Cart creation response: \(json)")
            } catch {
                print("Error parsing cart creation response: \(error.localizedDescription)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let dataObject = json["data"] as? [String: Any],
                   let id = dataObject["id"] as? String {
                    print("Successfully created cart with ID: \(id)")
                    completion(.success(id))
                } else {
                    print("Failed to parse cart ID from response")
                    completion(.failure(NSError(domain: "Invalid response format", code: 0, userInfo: nil)))
                }
            } catch {
                print("Error parsing cart creation response: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

    private func addItemsToCart(token: String, cartId: String) {
        let group = DispatchGroup()
        
        for item in appState.cartItems {
            group.enter()
            addToCart(token: token, cartId: cartId, product: item.product, quantity: item.quantity) { result in
                switch result {
                case .success:
                    print("Successfully added \(item.product.name) to cart")
                case .failure(let error):
                    print("Failed to add \(item.product.name) to cart: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.placeOrderWithSpryker(token: token, cartId: cartId)
        }
    }

    private func addToCart(token: String, cartId: String, product: Product, quantity: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Starting add to cart for product: \(product.sku), quantity: \(quantity)")
        guard let url = URL(string: "\(urlPrefix)/carts/\(cartId)/items") else {
            print("Error: Invalid URL for add to cart")
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "data": [
                "type": "items",
                "attributes": [
                    "sku": product.sku,
                    "quantity": quantity,
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            print("Request body for add to cart created successfully")
        } catch {
            print("Error creating request body for add to cart: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error during add to cart: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received from add to cart request")
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            print("Received response from Spryker Glue for add to cart, data size: \(data.count) bytes")

            // output the json
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("Add to cart response: \(json)")
            } catch {
                print("Error parsing add to cart response: \(error.localizedDescription)")
            }
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                print("Successfully added item to cart")
                completion(.success(()))
            } else {
                print("Failed to add item to cart")
                completion(.failure(NSError(domain: "Failed to add item", code: 0, userInfo: nil)))
            }
        }.resume()
    }
    
    private func placeOrderWithSpryker(token: String, cartId: String) {
        print("Starting order placement with Spryker")
        guard let url = URL(string: "\(urlPrefix)/checkout") else {
            print("Error: Invalid URL for order placement")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let orderItems = appState.cartItems.map { item in
            item.product.sku
        }
        print("Order items: \(orderItems)")
        
        let body: [String: Any] = [
            "data": [
                "type": "checkout",
                "attributes": [
                    "customer": [
                        "email": "spencor.hopkin@spryker.com",
                        "salutation": "Mr",
                        "firstName": "Spencor",
                        "lastName": "Hopkin"
                    ],
                    "idCart": cartId,
                    "billingAddress": [
                        "id": "address1",
                        "salutation": "Mr",
                        "firstName": "John",
                        "lastName": "Doe",
                        "address1": "123 Main St",
                        "address2": "Apt 4B",
                        "address3": "",
                        "zipCode": "12345",
                        "city": "New York",
                        "iso2Code": "US",
                        "company": "Acme Inc",
                        "phone": "+1234567890",
                        "isDefaultBilling": true,
                        "isDefaultShipping": false
                    ],
                    "shippingAddress": [
                        "id": "address2",
                        "salutation": "Mr",
                        "firstName": "John",
                        "lastName": "Doe",
                        "address1": "456 Elm St",
                        "address2": "",
                        "address3": "",
                        "zipCode": "67890",
                        "city": "Los Angeles",
                        "iso2Code": "US",
                        "company": "",
                        "phone": "+1987654321",
                        "isDefaultBilling": false,
                        "isDefaultShipping": true
                    ],
                    "payments": [
                        [
                            "paymentProviderName": "DummyPayment",
                            "paymentMethodName": "Credit Card",
                            "paymentSelection": "dummyPaymentCreditCard"
                        ]
                    ],
                    "shipment": [
                        "idShipmentMethod": 1
                    ],
                    "shipments": [
                        [
                            "shippingAddress": [
                                "id": "address2",
                                "salutation": "Mr",
                                "firstName": "John",
                                "lastName": "Doe",
                                "address1": "456 Elm St",
                                "address2": "",
                                "address3": "",
                                "zipCode": "67890",
                                "city": "Los Angeles",
                                "iso2Code": "US",
                                "company": "",
                                "phone": "+1987654321",
                                "isDefaultBilling": false,
                                "isDefaultShipping": true
                            ],
                            "items": orderItems,
                            "idShipmentMethod": 1,
                            "requestedDeliveryDate": "2023-12-31"
                        ]
                    ]
                ]
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            print("Order placement request body created successfully")
        } catch {
            print("Error creating order placement request body: \(error.localizedDescription)")
            return
        }
        
        print("Sending order placement request to Spryker")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Order placement failed: \(error.localizedDescription)")
                    self.checkoutStatus = .notStarted
                } else if let data = data {
                    print("Order placement response received, data size: \(data.count) bytes")
                    print("Order placed successfully")
                    self.checkoutStatus = .success
                    self.appState.cartItems.removeAll()
                } else {
                    print("Order placement completed but no data received")
                    self.checkoutStatus = .notStarted
                }
                self.isCheckingOut = false
            }
        }.resume()
    }
}

enum CheckoutStatus {
    case notStarted
    case processing
    case success
}

#Preview {
    OskarSupport()
}
