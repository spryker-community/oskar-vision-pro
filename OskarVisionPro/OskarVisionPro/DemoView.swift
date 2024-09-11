//
//  DemoView.swift
//  OskarVisionPro
//
//  Created by Phil Miletic on 11.09.24.
//

import RealityKit
import SwiftUI

struct DemoView: View {
    @State var rotationAngle: Float = 0
    @State var timer: Timer?
    let url: URL
    
    var body: some View {
        RealityView { content in
            // Download usdz file, save to documents, load file, and swap material
            let (downloadedURL, _) = try! await URLSession.shared.download(from: url)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let destinationURL = documentsDirectory.appendingPathComponent("downloadedModel.usdz")
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try! FileManager.default.removeItem(at: destinationURL)
            }
            try! FileManager.default.moveItem(at: downloadedURL, to: destinationURL)
            let entity = try! await ModelEntity.init(contentsOf: destinationURL)
            entity.model?.materials = [goldMaterial]
            content.add(entity)
            try! FileManager.default.removeItem(at: destinationURL)
        } update: { content in
            if let entity = content.entities.first {
                entity.transform.rotation = simd_quatf(angle: rotationAngle, axis: [0, 1, 0])
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }
    
    var goldMaterial: PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()
        material.baseColor.tint = .init(red: 0.75, green: 0.75, blue: 0.5, alpha: 1.0)
        material.roughness = 0.0
        material.metallic = 1.0
        material.faceCulling = .none
        return material
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            rotationAngle += 0.01
            if rotationAngle >= .pi * 2 {
                rotationAngle = 0
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    DemoView(url: URL(string: "https://matt54.github.io/Resources/StatueOfBuddha.usdz")!)
}
