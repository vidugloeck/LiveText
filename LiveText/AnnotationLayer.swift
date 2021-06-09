/*
 Copyright © 2021 Apple Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 Abstract:
 A layer subclass that highlights text.
 */

import UIKit
import QuartzCore

class AnnotationLayer: CALayer {
    var results: [DisplayResult] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var textFilter: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(in ctx: CGContext) {
        guard !results.isEmpty else {
            opacity = 0.0
            return
        }
        
        // Fill the clip bounds with an opaque overlay.
        ctx.setFillColor(UIColor.black.cgColor)
        let clipBounds = ctx.boundingBoxOfClipPath
        ctx.fill(clipBounds)
        
        ctx.saveGState()
        
        // Flip Coordinate System
        let transfrom = CGAffineTransform.init(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(ctx.height))
        ctx.concatenate(transfrom)
        
        // Highlight the result boxes.
        ctx.setFillColor(UIColor.white.cgColor)
        let width = bounds.size.width
        let height = bounds.size.height
        let cgPath = CGMutablePath()
        for result in self.results {
            if textFilter.isEmpty || result.text.contains(textFilter) {
                cgPath.move(to: CGPoint(x: result.bottomLeft.x * width, y: result.bottomLeft.y * height))
                cgPath.addLine(to: CGPoint(x: result.bottomRight.x * width, y: result.bottomRight.y * height))
                cgPath.addLine(to: CGPoint(x: result.topRight.x * width, y: result.topRight.y * height))
                cgPath.addLine(to: CGPoint(x: result.topLeft.x * width, y: result.topLeft.y * height))
                cgPath.addLine(to: CGPoint(x: result.bottomLeft.x * width, y: result.bottomLeft.y * height))
                
            }
        }
        
        ctx.addPath(cgPath)
        ctx.fillPath()
        
        ctx.addPath(cgPath)
        
        ctx.setLineWidth(2.0)
        ctx.setStrokeColor(CGColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0))
        ctx.strokePath()
        
        ctx.restoreGState()
        
        opacity = 0.5
    }
}


