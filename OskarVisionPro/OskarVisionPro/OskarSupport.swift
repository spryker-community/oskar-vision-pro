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
                    simulateCheckout()
                }) {
                    if isCheckingOut {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Checkout")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                    }
                }
                .disabled(isCheckingOut)
                .background(isCheckingOut ? Color.gray : Color.blue)
                .cornerRadius(10)
                .padding(.top)
                
                if checkoutStatus != .notStarted {
                    Text(checkoutStatus.message)
                        .foregroundColor(.green)
                        .padding(.top)
                }
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
    
    private func simulateCheckout() {
        checkoutStatus = .processing
        
        // Simulate a network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            checkoutStatus = .success
            appState.cartItems.removeAll()
            isCheckingOut = false
        }
    }
}

enum CheckoutStatus {
    case notStarted
    case processing
    case success
    
    var message: String {
        switch self {
        case .notStarted:
            return ""
        case .processing:
            return "Processing your order..."
        case .success:
            return "Order placed successfully!"
        }
    }
}

#Preview {
    OskarSupport()
}
