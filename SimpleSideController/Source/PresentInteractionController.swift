//
//  InteractionController.swift
//  SimpleSideController
//
//  Created by Alessandro Martin on 04/09/16.
//  Copyright © 2016 Alessandro Martin. All rights reserved.
//

import UIKit

class PresentInteractionController: UIPercentDrivenInteractiveTransition {
    var isInProgress = false
    private var shouldCompleteTransition = false
    private weak var simpleSideController: SimpleSideController?
    
    init(simpleSideController: SimpleSideController) {
        self.simpleSideController = simpleSideController
        
        super.init()
        
        simpleSideController.panGestureRecognizer = UIPanGestureRecognizer()
        simpleSideController.panGestureRecognizer?.maximumNumberOfTouches = 1
        simpleSideController.panGestureRecognizer?.addTarget(self, action: #selector(handleSwipeGesture(gr:)))
        simpleSideController.view.addGestureRecognizer(simpleSideController.panGestureRecognizer!)
    }
    
    @objc fileprivate func handleSwipeGesture(gr: UIPanGestureRecognizer) {
        guard let simpleSideController = self.simpleSideController,
            let grView = gr.view else { return }
        
        let translation = gr.translation(in: grView)
        var progress = translation.x / simpleSideController.sideContainerViewController.view.frame.width
        progress = clamp(lowerBound: 0.0, value: progress, upperBound: 1.0)
        
        switch gr.state {
        case .began:
            if let opacity = simpleSideController.shadow?.opacity, simpleSideController._state == .front {
                simpleSideController.sideContainerViewController.view.displayShadow(opacity: opacity)
            }
            
            simpleSideController._state = .transitioning
            self.isInProgress = true
            simpleSideController._state = .side
        case .changed:
            self.shouldCompleteTransition = (progress > 0.5)
            self.update(progress)
        case .cancelled:
            self.isInProgress = false
            self.cancel()
        case .ended:
            self.isInProgress = false
            if !self.shouldCompleteTransition {
                self.cancel()
            } else {
                self.finish()
            }
        default:
            break
        }
    }
}
