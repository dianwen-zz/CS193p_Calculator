//
//  GraphingView.swift
//  Calculator
//
//  Created by Dan Li on 4/25/15.
//  Copyright (c) 2015 Dan Li . All rights reserved.
//

import UIKit

protocol GraphingViewDataSource: class {
    func calculateYValue(variableName: String, sender: GraphingView, xValue: Double) -> Double?
}

@IBDesignable
class GraphingView: UIView {
    weak var dataSource: GraphingViewDataSource?
    
    @IBInspectable
    var scale: CGFloat =  50 { didSet { setNeedsDisplay() } }
    
    var viewCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    var panOffset: CGPoint = CGPointZero

    override func drawRect(rect: CGRect) {
        let axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
        axesDrawer.drawAxesInRect(bounds, origin: CGPointMake(viewCenter.x + panOffset.x, viewCenter.y + panOffset.y), pointsPerUnit: scale)
        let path = UIBezierPath()
        let pixelWidth = Int(rect.size.width*contentScaleFactor)
        var previousPointLocation = CGPointZero
        var skippedPoint = true
        for i in 0 ..< pixelWidth {
            let unitLocationX = pixelXToUnitLocation(Double(i))
            if let unitLocationY = dataSource?.calculateYValue("M", sender: self, xValue: unitLocationX) {
                if !unitLocationY.isNaN{
                    let pointLocationY = unitLocationYToPixel(unitLocationY)/Double(contentScaleFactor)
                    let pointLocationX = Double(i)/Double(contentScaleFactor)
                    previousPointLocation = CGPointMake(CGFloat(pointLocationX), CGFloat(pointLocationY))
                    if skippedPoint {
                        path.moveToPoint(previousPointLocation)
                        skippedPoint = false
                    }
                    else {
                        path.addLineToPoint(previousPointLocation)
                    }
                }
                else {
                    skippedPoint = true
                }
            }
        }
        path.stroke()
    }
    
    func pixelXToUnitLocation(px: Double) -> Double {
        return (px-Double(viewCenter.x+panOffset.x)*Double(contentScaleFactor))/Double(contentScaleFactor)/Double(scale)
    }
    
    func unitLocationYToPixel(unitLoc: Double) -> Double {
        return -unitLoc*Double(contentScaleFactor)*Double(scale)+Double(viewCenter.y+panOffset.y)*Double(contentScaleFactor)
    }
}
