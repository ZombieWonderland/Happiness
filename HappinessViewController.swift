//
//  HappinessViewController.swift
//  Happiness
//
//  Created by Dan Livingston  on 3/21/16.
//  Copyright © 2016 Some Peril. All rights reserved.
//

import UIKit

class HappinessViewController: UIViewController, FaceViewDataSource
{
    // Model
    var happiness: Int = 50 { // 0 = very sad, 100 = ecstatic
        didSet {
            // Keep it from 0 to 100, inclusive
            happiness = min(max(happiness, 0), 100)
            updateUI()
        }
    }
    
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            // do it here, because the controller contains the model
            // which acts as the source of the data (smiliness)
            // for the faceView
            faceView.dataSource = self
            
            // adding a gesture via code
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: #selector(FaceView.scale)))
        }
    }
    
    private struct Constants {
        static let HappinessGestureScale: CGFloat = 4
    }
    
    // adding a gesture via storyboard
    @IBAction func changeHappiness(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(faceView)
            let happinessChange = -Int(translation.y / Constants.HappinessGestureScale)
            if happinessChange != 0 {
                happiness += happinessChange
                gesture.setTranslation(CGPointZero, inView: faceView)
            }
        default: break
        }
    }
    
    
    private func updateUI() {
        faceView.setNeedsDisplay()
    }
    
    func smilinessForFaceView(sender: FaceView) -> Double? {
        return Double(happiness-50)/50
    }


}
