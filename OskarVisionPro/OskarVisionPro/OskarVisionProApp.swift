//
//  OskarVisionProApp.swift
//  OskarVisionPro
//
//  Created by Phil Miletic on 11.09.24.
//

import SwiftUI

@main
struct OskarVisionProApp: App {
    @State private var selectedProduct: Product?
    @State private var selectedCategory: Category?
    
    var body: some Scene {
        WindowGroup(id: "main") {
            VStack(spacing: 20) { // Added spacing for a gap
                HeaderView()
                HStack(alignment: .top, spacing: 20) {
                    ProductListView(selectedProduct: $selectedProduct, selectedCategory: $selectedCategory)
                    VStack {
                        CategoryList(selectedCategory: $selectedCategory)
                        ContentView(product: selectedProduct)
                    }
                    OskarSupport()
                }
            }
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)

        WindowGroup(id: "animation") {
            if let product = selectedProduct, let modelURL = product.productModel, let url = URL(string: modelURL) {
                Model3DView(url: url)
            } else {
                Text("No 3D model available")
            }
        }
        .windowStyle(.plain)
        .windowResizability(.automatic)
    }
}
