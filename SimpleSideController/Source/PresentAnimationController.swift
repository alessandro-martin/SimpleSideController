//
//  PresentAnimationController.swift
//  SimpleSideController
//
//  Created by Alessandro Martin on 04/09/16.
//  Copyright © 2016 Alessandro Martin. All rights reserved.
//

import UIKit

class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    let initialFrame: CGRect
    private weak var simpleSideController: SimpleSideController?
    private(set) var transitionView: UIView?
    
    init(simpleSideController: SimpleSideController) {
        self.simpleSideController = simpleSideController
        self.initialFrame = simpleSideController.sideContainerViewController.view.frame
        print(self.initialFrame)
        
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let simpleSideController = self.simpleSideController,
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true) else { return }
        
        self.transitionView = transitionContext.containerView
        snapshot.frame = self.initialFrame
        self.transitionView?.addSubview(toVC.view)
        self.transitionView?.addSubview(snapshot)
        self.transitionView?.addGestureRecognizer(simpleSideController.tapGestureRecognizer)
        toVC.view.isHidden = true
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: .calculationModeLinear,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 1.0,
                                                       animations: {
                                                        toVC.view.frame = CGRect(origin: .zero, size: toVC.view.frame.size)
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                       relativeDuration: 1.0, animations: {
                                                        snapshot.frame = CGRect(origin: .zero, size: toVC.view.frame.size)
                                    })
                                    if case let .dim(_, dimColor) = simpleSideController.background {
                                        UIView.addKeyframe(withRelativeStartTime: 0.0,
                                                           relativeDuration: 1.0,
                                                           animations: {
                                                            self.transitionView?.backgroundColor = dimColor
                                        })
                                    }
        }) { _ in
            toVC.view.isHidden = false
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            //            simpleSideController.panGestureRecognizer.view?.removeGestureRecognizer(simpleSideController.panGestureRecognizer)
            //            self.transitionView?.addGestureRecognizer(simpleSideController.panGestureRecognizer)
        }
    }
}
