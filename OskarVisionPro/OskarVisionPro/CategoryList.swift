//
//  CategoryList.swift
//  OskarVisionPro
//
//  Created by Phil Miletic on 11.09.24.
//

import SwiftUI

struct CategoryList: View {
    @Binding var selectedCategory: Category?
    @State private var localCategories: [Category] = []
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(localCategories) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        HStack {
                            Image(systemName: "star.fill") // Dummy icon
                                .foregroundColor(.primary)
                            Text(category.name)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .foregroundColor(.primary)
                        .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .background(selectedCategory?.name == category.name ? Color.blue.opacity(0.3) : Color.clear)
                    .cornerRadius(15)
                }
            }
            .padding()
        }
        .frame(height: 60)
        .glassBackgroundEffect()
        .onAppear {
            fetchCategories {
                self.localCategories = categories
            }
        }
    }
}

#Preview {
    CategoryList(selectedCategory: .constant(nil))
}
