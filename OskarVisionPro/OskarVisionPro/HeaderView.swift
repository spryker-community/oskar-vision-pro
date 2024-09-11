//
//  HeaderView.swift
//  OskarVisionPro
//
//  Created by Phil Miletic on 11.09.24.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        Text("Welcome to Oskar's Shop")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .glassBackgroundEffect()
    }
}

#Preview {
    HeaderView()
}
