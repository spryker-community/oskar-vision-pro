//
//  OskarSupport.swift
//  OskarVisionPro
//
//  Created by Phil Miletic on 11.09.24.
//

import SwiftUI

struct OskarSupport: View {
    @State private var cartItems: [CartItem] = [] // Assuming CartItem is defined elsewhere
    
    var body: some View {
        VStack {
            Text("Cart")
                .padding(.bottom)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Cart Summary")
                    .font(.headline)
                
                ForEach(cartItems) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("$\(item.price, specifier: "%.2f")")
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
                    // Implement checkout action
                    print("Proceeding to checkout")
                }) {
                    Text("Checkout")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
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
        cartItems.reduce(0) { $0 + $1.price }
    }
}

struct CartItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
}

#Preview {
    OskarSupport()
}
