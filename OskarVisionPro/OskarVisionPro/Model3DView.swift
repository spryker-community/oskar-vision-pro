//
//  Model3DView.swift
//  OskarVisionPro
//
//  Created by Philipp Lammers on 11.09.24.
//

import SwiftUI
import RealityKit
import SceneKit

struct Model3DView: View {
    @State private var currentScale: Float = 1.0
    @State private var currentTranslation: SIMD3<Float> = SIMD3<Float>(0, 0, 0)
    @State private var angle = Angle(degrees: 0.0);

    // Replace this with your 3D model's URL
    let modelURL = URL(string: "https://essay-alerts-city-always.trycloudflare.com/models/box.usdz")!

    var body: some View {
        ZStack {
            Model3DViewContainer(url: modelURL, currentScale: $currentScale, currentTranslation: $currentTranslation,
                angle: $angle
            
            )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // Update the translation of the 3D model
                            let translation = SIMD3<Float>(Float(value.translation.width) / 1000, Float(-value.translation.height) / 1000, 0)
                            currentTranslation = translation
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            // Update the scale of the 3D model
                            currentScale = Float(value)
                        }
                )
                .gesture(
                    RotateGesture()
                        .onChanged { value in
                            angle = value.rotation
                        }
                )
        }
    }
}

struct Model3DViewContainer: View {
    let url: URL
    @Binding var currentScale: Float
    @Binding var currentTranslation: SIMD3<Float>
    @Binding var angle: Angle;

    var body: some View {
        Model3D(url: url)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        currentScale = Float(value)
                    }
                
            )
            .scaleEffect(CGFloat(currentScale))
            .offset(x: CGFloat(currentTranslation.x), y: CGFloat(currentTranslation.y))
            .rotationEffect(angle)
    }
}

#Preview {
    Model3DView()
}
