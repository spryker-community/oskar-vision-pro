import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    let product: Product?
    @State private var isLoading3DModel = false
    @State private var show3DModel = false
    @State private var modelURL: String = ""
    @State private var quantity: Int = 1

    @StateObject private var appState = AppState.shared
    
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            // ---- Main Content ---------------------------------------------------
            HStack(alignment: .top) {
                // ---- Middle Pane ---------------------------------------------------
                VStack {
                    // ---- Product Detail -----------------------------------------------------
                    if let product = product {
                        ScrollView {
                            VStack(alignment: .leading) {
                                // ---- Product General Info -----------------------------------------
                                HStack {
                                    // Title, Category, Rating
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(product.name)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        Text("Rocking chair, Gunnard light green")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        HStack {
                                            ForEach(0..<5) { index in
                                                Image(systemName: index < 4 ? "star.fill" : "star")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 14))
                                            }
                                            Text("4.8")
                                                .foregroundColor(.white)
                                                .font(.system(size: 14))
                                                .padding(.leading, 4)
                                        }
                                    }

                                    // Spacer
                                    Spacer()

                                    // Price
                                    Text(String(format: "$%.2f", product.price))
                                        .font(.system(size: 48))
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                }

                                // ---- Product Description -----------------------------------------
                                Text(product.description)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 10)

                                // ---- Horizontal Seperator -----------------------------------------
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 10)

                                // ---- Quantity and Add to Cart -----------------------------------------
                                HStack {
                                    HStack {
                                        Button(action: {
                                            if quantity > 1 {
                                                quantity -= 1
                                            }
                                        }) {
                                            Image(systemName: "minus.circle")
                                                .foregroundColor(.primary)
                                        }
                                        .background(Color.clear)
                                        
                                        Text("\(quantity)")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .frame(minWidth: 40)
                                        
                                        Button(action: {
                                            quantity += 1
                                        }) {
                                            Image(systemName: "plus.circle")
                                                .foregroundColor(.primary)
                                        }
                                        .background(Color.clear)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .glassBackgroundEffect()
                                    .cornerRadius(10)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        self.appState.cartItems.append((product, quantity))
                                    }) {
                                        Text("Add to Cart")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .cornerRadius(10)
                                    }
                                }
                                .padding(.vertical, 10)
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 10)

                                // ---- 3D Model Button -----------------------------------------
                                Button(action: {
                                    openWindow(id: "animation")
                                }) {
                                    Text("View 3D Model")
                                        .font(.system(size: 14))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding()
                                        .cornerRadius(10)
                                }
                                .disabled(isLoading3DModel)
                            }
                            .padding(.vertical, 80)
                            .padding(.horizontal, 80)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .glassBackgroundEffect()
                    } else {
                        Text("Select a product to view details")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .glassBackgroundEffect()
                    }
                }
                .frame(width: 800)
                .padding()

                // ---- Right Pane ---------------------------------------------------
                VStack {
                    
                }
            }
        }
    }
}

#Preview {
    ContentView(product: nil)
}
