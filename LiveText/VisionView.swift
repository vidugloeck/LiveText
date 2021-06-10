//
//  VisionView.swift
//  LiveText
//
//  Created by Vidu Glöck on 09.06.21.
//

import SwiftUI
import UIKit


struct VisionView: UIViewRepresentable {
    let image: UIImage
    var ocrResults: [OCRResult]?
    
    func makeUIView(context: Context) -> UIView {
        VisionUIView(image: image)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let view = uiView as? VisionUIView else { return }
        view.ocrResults = ocrResults ?? []
    }
    
    
}

fileprivate class VisionUIView: UIView {
    var image: UIImage {
        didSet {
            updateImage()
        }
    }
    
    var ocrResults: [OCRResult] = [] {
        didSet {
            annotationLayer.results = ocrResults
        }
    }
    var imageLayer: CALayer = CALayer()
    var annotationLayer: AnnotationLayer = AnnotationLayer()
    override var frame: CGRect {
        didSet {
            imageLayer.frame = frame
            annotationLayer.frame = frame
        }
    }
    init(image: UIImage) {
        self.image = image
        super.init(frame: .zero)
        setupLayers()
        updateImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayers() {
        imageLayer.frame = layer.bounds
        imageLayer.contentsGravity = .resizeAspect
        layer.addSublayer(imageLayer)
        
        annotationLayer.bounds = layer.bounds
        annotationLayer.contentsGravity = .resizeAspect
        annotationLayer.opacity = 0.0
        layer.insertSublayer(annotationLayer, above: imageLayer)
    }
    
    private func updateContentSize(w width: CGFloat, h height: CGFloat) {
        let newFrame = CGRect(x: 0, y: 0, width: width, height: height)
//        let newFrame = bounds
        // Update the image layer.
        imageLayer.frame = newFrame
        frame = newFrame
        
        // Update the annotation layer.
        annotationLayer.frame = newFrame
        annotationLayer.setNeedsDisplay()
    }
    
    private func updateImage() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        
        imageLayer.contents = self.image.cgImage
        updateContentSize(w: CGFloat(image.size.width), h: CGFloat(image.size.height))
        
        CATransaction.commit()
    }
}
