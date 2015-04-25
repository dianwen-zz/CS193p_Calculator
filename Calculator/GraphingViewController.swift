//
//  GraphingViewController.swift
//  Calculator
//
//  Created by Dan Li on 4/25/15.
//  Copyright (c) 2015 Dan Li . All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController {
    
    @IBOutlet weak var graphingView: GraphingView!
    
    private struct Constants {
        static let PanGestureScale: CGFloat = 1
    }
    
    @IBAction func changeScale(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            graphingView.scale *= gesture.scale
            gesture.scale = 1
        }
    }
    
    @IBAction func panGraph(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(graphingView)
            if translation.x != 0 || translation.y != 0 {
                graphingView.panOffset = CGPointMake(graphingView.panOffset.x + translation.x / Constants.PanGestureScale, graphingView.panOffset.y + translation.y / Constants.PanGestureScale)
                gesture.setTranslation(CGPointZero, inView: graphingView)
                updateUI()
            }
        default: break
        }
    }
    
    func updateUI() {
        graphingView.setNeedsDisplay()
    }
}
