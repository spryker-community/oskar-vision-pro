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
    @State private var rotationAxis: (x: CGFloat, y: CGFloat, z: CGFloat) = (x: 0.0, y: 0.0, z: 0.0);
    @State private var rotation = Angle(degrees: 0.0);
    let url: URL

    // Replace this with your 3D model's URL
    let modelURL = URL(string: "https://essay-alerts-city-always.trycloudflare.com/models/box.usdz")!

    var body: some View {
        ZStack {
            Model3DViewContainer(url: url, currentScale: $currentScale, currentTranslation: $currentTranslation)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let angle = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                            rotation = Angle(degrees: Double(angle))

                            let axisX = -value.translation.height / CGFloat(angle)
                            let axisY = value.translation.width / CGFloat(angle)

                            rotationAxis = (x: axisX, y: axisY, z: 0)

                            // Update the translation of the 3D model
                            let translation = SIMD3<Float>(Float(value.translation.width) / 1000, Float(-value.translation.height) / 1000, 0)
                            currentTranslation = translation
                        }
                )
                rotation3DEffect(rotation, axis: rotationAxis)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            // Update the scale of the 3D model
                            currentScale = Float(value)
                        }
                )
        }
    }
}

struct Model3DViewContainer: View {
    let url: URL
    @Binding var currentScale: Float
    @Binding var currentTranslation: SIMD3<Float>

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
            placeholder: do {
               ProgressView()

        }
    }
}

#Preview {
    Model3DView(url: URL(string: "https://essay-alerts-city-always.trycloudflare.com/models/box.usdz")!)
}
