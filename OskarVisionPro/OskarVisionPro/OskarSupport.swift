//
//  OskarSupport.swift
//  OskarVisionPro
//
//  Created by Phil Miletic on 11.09.24.
//

import SwiftUI

struct OskarSupport: View {
    var body: some View {
        VStack {
            Text("Ask Oskar anything about the product.")
        }
        .frame(width: 300, alignment: .leading)
        .padding()
        .glassBackgroundEffect()
    }
}

#Preview {
    OskarSupport()
}
