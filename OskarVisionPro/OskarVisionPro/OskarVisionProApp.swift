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
    
    var body: some Scene {
        WindowGroup {
            VStack {
                HeaderView()
                HStack {
                    ProductListView(selectedProduct: $selectedProduct)
                    ContentView(product: selectedProduct)
                }
            }
            //Model3DView()
        }
        .windowStyle(.plain)
        .windowResizability(.contentSize)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
