//
//  FaceView.swift
//  Happiness
//
//  Created by Dan Livingston  on 3/21/16.
//  Copyright © 2016 Some Peril. All rights reserved.
//

import UIKit

protocol FaceViewDataSource: class {
    func smilinessForFaceView(sender: FaceView) -> Double?
}

@IBDesignable
class FaceView: UIView
{
    @IBInspectable
    var lineWidth: CGFloat = 3 { didSet { setNeedsDisplay() } } // when this changes, face needs to be redrawn
    @IBInspectable
    var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    @IBInspectable
    var scale: CGFloat = 0.9 { didSet { setNeedsDisplay() } }
    var faceCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    var faceRadius: CGFloat {
        return min(bounds.size.width, bounds.size.height) / 2 * scale
    }
    
    weak var dataSource: FaceViewDataSource?
    
    func scale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1   // reset scale
        }
    }
    
    private struct Scaling {
        static let FaceRadiusToEyeRadiusRatio: CGFloat = 20
        static let FaceRadiusToEyeOffsetRatio: CGFloat = 3
        static let FaceRadiusToEyeSeparationRatio: CGFloat = 1.5
        
        static let FaceRadiusToEyebrowWidthRatio: CGFloat = 3
        static let FaceRadiusToEyebrowHeightRatio: CGFloat = 5
        static let FaceRadiusToEyebrowOffsetRatio: CGFloat = 1.8
        static let FaceRadiusToEyebrowSeparationRatio: CGFloat = 1.5
        
        static let FaceRadiusToMouthWidthRatio: CGFloat = 0.7
        static let FaceRadiusToMouthHeightRatio: CGFloat = 3
        static let FaceRadiusToMouthOffsetRatio: CGFloat = 3
    }
    
    private enum Eye { case Left, Right }
    private enum Eyebrow { case Left, Right }
    
    private func bezierPathForEye(whichEye: Eye) -> UIBezierPath {
        let eyeRadius = faceRadius/Scaling.FaceRadiusToEyeRadiusRatio
        let eyeVerticalOffset = faceRadius/Scaling.FaceRadiusToEyeOffsetRatio
        let eyeHorizontalSeparation = faceRadius/Scaling.FaceRadiusToEyeSeparationRatio
        
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeVerticalOffset
        
        switch whichEye {
        case .Left: eyeCenter.x -= eyeHorizontalSeparation / 2
        case .Right: eyeCenter.x += eyeHorizontalSeparation / 2
        }
        
        let path = UIBezierPath(arcCenter: eyeCenter, radius: eyeRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        path.lineWidth = lineWidth
        return path
    }
    
    private func bezierPathForEyebrow(whichEyebrow: Eyebrow, fractionOfMaxSmile: Double) -> UIBezierPath {
        let eyebrowWidth = faceRadius / Scaling.FaceRadiusToEyebrowWidthRatio
        let eyebrowHeight = faceRadius / Scaling.FaceRadiusToEyebrowHeightRatio
        let eyebrowVerticalOffset = faceRadius / Scaling.FaceRadiusToEyebrowOffsetRatio
        let eyebrowHorizontalSeparation = faceRadius / Scaling.FaceRadiusToEyebrowSeparationRatio
        
        var eyebrowCenter = faceCenter
        eyebrowCenter.y -= eyebrowVerticalOffset
                
        let browArchHeight = CGFloat(max (min (fractionOfMaxSmile, 1), -1)) * eyebrowHeight
        
        switch whichEyebrow {
        case .Left: eyebrowCenter.x -= eyebrowHorizontalSeparation / 2
        case .Right: eyebrowCenter.x += eyebrowHorizontalSeparation / 2
        }
        
        // now the center of both eyebrows are set
        let start = CGPoint(x: eyebrowCenter.x - eyebrowWidth/2, y: eyebrowCenter.y)
        let end = CGPoint(x: start.x + eyebrowWidth, y: start.y)
        let cp1 = CGPoint(x: start.x + eyebrowHeight/3, y: start.y - browArchHeight)
        let cp2 = CGPoint(x: end.x - eyebrowHeight/3, y: cp1.y)
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        
        return path
    }
    
    // fractionOfMaxSmile:
    //      +1 is full smile
    //      -1 is full frown
    //      0 is full meh
    private func bezierPathForSmile(fractionOfMaxSmile: Double) -> UIBezierPath
    {
        let mouthWidth = faceRadius / Scaling.FaceRadiusToMouthWidthRatio
        let mouthHeight = faceRadius / Scaling.FaceRadiusToMouthHeightRatio
        let mouthVerticalOffset = faceRadius / Scaling.FaceRadiusToMouthOffsetRatio
        
        let smileHeight = CGFloat(max (min (fractionOfMaxSmile, 1), -1)) * mouthHeight
        
        let start = CGPoint(x: faceCenter.x - mouthWidth / 2, y: faceCenter.y + mouthVerticalOffset)
        let end = CGPoint(x: start.x + mouthWidth, y: start.y)
        let cp1 = CGPoint(x: start.x + mouthWidth/3, y: start.y + smileHeight)
        let cp2 = CGPoint(x: end.x - mouthWidth/3, y: cp1.y)
        
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addCurveToPoint(end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = lineWidth
        
        return path
    }


    override func drawRect(rect: CGRect)
    {
        let facePath = UIBezierPath(arcCenter: faceCenter, radius: faceRadius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        facePath.lineWidth = lineWidth
        color.set()
        facePath.stroke()
        
        bezierPathForEye(.Left).stroke()
        bezierPathForEye(.Right).stroke()
        
        let smiliness = dataSource?.smilinessForFaceView(self) ?? 0.0
        let smilePath = bezierPathForSmile(smiliness)
        smilePath.stroke()
        
        bezierPathForEyebrow(.Left, fractionOfMaxSmile: smiliness).stroke()
        bezierPathForEyebrow(.Right, fractionOfMaxSmile: smiliness).stroke()
    }


}
