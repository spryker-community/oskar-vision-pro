import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    let product: Product?
    
    var body: some View {
        VStack {
            // ---- Main Content ---------------------------------------------------
            HStack(alignment: .top) {
                // ---- Middle Pane ---------------------------------------------------
                VStack {
                    // ---- Product Detail -----------------------------------------------------
                    if let product = product {
                        ScrollView {
                            ZStack(alignment: .topTrailing) {
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
                                }
                                .padding(.vertical, 80)
                                .padding(.horizontal, 80)
                                .frame(maxWidth: .infinity, alignment: .leading)

                                // ---- Product Image -----------------------------------------
                                AsyncImage(url: URL(string: product.imageURL)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 300, height: 300)
                                        .padding(.top, 200)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
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
                    // ---- Oskar Support -----------------------------------------------------
                    VStack {
                        Text("Ask Oskar anything about the product.")
                    }
                    .frame(width: 300, alignment: .leading)
                    .padding()
                    .glassBackgroundEffect()
                }
            }
        }
    }
}

#Preview {
    ContentView(product: nil)
}
