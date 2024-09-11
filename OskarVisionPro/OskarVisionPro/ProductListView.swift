//
//  ProductListView.swift
//  OskarVisionPro
//
//  Created by Phil Miletic on 11.09.24.
//

import SwiftUI

struct ProductListView: View {
    @State private var products: [Product] = OskarVisionPro.products
    @Binding var selectedProduct: Product?

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
                        .onTapGesture {
                            selectedProduct = product
                        }
                    }
                }
            }
        }
        .frame(width: 300)
        .padding(.top, 20)
        .glassBackgroundEffect()
    }
}

#Preview {
    ProductListView(selectedProduct: .constant(nil))
}
