//
//  DismissAnimationController.swift
//  SimpleSideController
//
//  Created by Alessandro Martin on 04/09/16.
//  Copyright © 2016 Alessandro Martin. All rights reserved.
//

import UIKit

class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    let finalFrame: CGRect
    let transitionView: UIView?
    private weak var simpleSideController: SimpleSideController?
    
    init(simpleSideController: SimpleSideController) {
        self.finalFrame = CGRect(x: -simpleSideController.sideControllerWidth,
                                 y: 0,
                                 width: simpleSideController.sideControllerWidth,
                                 height: UIScreen.main.bounds.height)
        self.transitionView = simpleSideController.presentAnimationController?.transitionView
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) else { return }
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: .calculationModeLinear,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 1.0,
                                                       animations: {
                                                        self.transitionView?.backgroundColor = .clear
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 1.0,
                                                       animations: {
                                                        fromVC.view.frame = self.finalFrame
                                    })
        }) { finished in
            if finished {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}
