//
//  GraphingView.swift
//  Calculator
//
//  Created by Dan Li on 4/25/15.
//  Copyright (c) 2015 Dan Li . All rights reserved.
//

import UIKit

@IBDesignable
class GraphingView: UIView {
    
    @IBInspectable
    var scale: CGFloat =  50 { didSet { setNeedsDisplay() } }
    
    var viewCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    var panOffset: CGPoint = CGPointZero

    override func drawRect(rect: CGRect) {
        let axesDrawer = AxesDrawer(contentScaleFactor: contentScaleFactor)
        axesDrawer.drawAxesInRect(bounds, origin: CGPointMake(viewCenter.x + panOffset.x, viewCenter.y + panOffset.y), pointsPerUnit: scale)
    }
    
}
