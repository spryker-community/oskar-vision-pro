import SwiftUI

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var cartItems: [(product: Product, quantity: Int)] = []
    
    private init() {}
}
