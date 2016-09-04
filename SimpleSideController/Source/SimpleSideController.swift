//
//  SimpleSideController.swift
//  SimpleSideController
//
//  Created by Alessandro Martin on 21/08/16.
//  Copyright © 2016 Alessandro Martin. All rights reserved.
//

import UIKit

public protocol SimpleSideControllerDelegate: class {
    func sideController(_ sideController: SimpleSideController, willChangeTo state: SimpleSideController.Presenting)
    func sideController(_ sideController: SimpleSideController, didChangeTo state: SimpleSideController.Presenting)
}

public struct Border {
    let thickness: CGFloat
    let color: UIColor
    
    public init(thickness: CGFloat, color: UIColor){
        self.thickness = thickness
        self.color = color
    }
}

public struct Shadow {
    let opacity: CGFloat
    let radius: CGFloat
    let width: CGFloat
    
    public init(opacity: CGFloat, radius: CGFloat, width: CGFloat) {
        self.opacity = opacity
        self.radius = radius
        self.width = width
    }
}

public class SimpleSideController: UIViewController {
    
    public enum Presenting {
        case front
        case side
        case transitioning
    }
    
    public enum Background {
        case opaque(backgroundColor: UIColor, shadow: Shadow?)
        case dim(backgroundColor: UIColor, dimColor: UIColor)
        case translucent(backgroundColor: UIColor, style: UIBlurEffectStyle)
        case vibrant(backgroundColor: UIColor, style: UIBlurEffectStyle)
    }
    
    static let speedThreshold: CGFloat = 300.0
    
    let sideContainerViewController = UIViewController()
    
    let borderView = UIView()
    var borderWidthConstraint: NSLayoutConstraint?
    
    public weak var delegate: SimpleSideControllerDelegate?
    
    public var state: Presenting {
        return self._state
    }
    
    public var border: Border? {
        didSet {
            self.borderView.backgroundColor = (border?.color) ?? .lightGray
            self.borderWidthConstraint?.constant = (border?.thickness) ?? 0.0
            self.sideContainerViewController.view.layoutIfNeeded()
        }
    }
    
    var _state: Presenting {
        willSet(newState) {
            switch newState {
            case .side:
                self.present(self.sideContainerViewController, animated: true, completion: nil)
            case .front:
                self.dismiss(animated: true, completion: nil)
            default: break
            }
            self.delegate?.sideController(self, willChangeTo: newState)
        }
        didSet {
            switch self._state {
            case .front:
                self.frontController.view.isUserInteractionEnabled = true
            default:
                break
            }
        }
    }
    
    var shadow: Shadow? {
        didSet {
            if self._state == .side {
                self.sideContainerViewController.view.layer.shadowOpacity = Float((self.shadow?.opacity) ?? 0.3)
                self.sideContainerViewController.view.layer.shadowRadius = (self.shadow?.radius) ?? 5.0
                self.sideContainerViewController.view.layer.shadowOffset = CGSize(width: ((self.shadow?.width) ?? 7.0) * (self.view.isRightToLeftLanguage() ? -1.0 : 1.0),
                                                                                  height: 0.0)
            }
        }
    }
    
    var background: Background {
        didSet {
            switch self.background {
            case let .opaque(backgroundColor, shadow):
                self.sideContainerViewController.view.backgroundColor = backgroundColor
                self.shadow = shadow
            case let .dim(backgroundColor, _):
                self.sideContainerViewController.view.backgroundColor = backgroundColor
            case let .translucent(backgroundColor, _), let .vibrant(backgroundColor, _):
                self.sideContainerViewController.view.backgroundColor = backgroundColor
            }
        }
    }
    
    var presentAnimationController: PresentAnimationController?
    fileprivate var dismissAnimationController: DismissAnimationController?
    fileprivate var presentInteractionController: PresentInteractionController?
    fileprivate var dismissInteractionController: DismissInteractionController?
    var frontController: UIViewController
    var sideController: UIViewController
    var panGestureRecognizer: UIPanGestureRecognizer?
    var tapGestureRecognizer = UITapGestureRecognizer()
    var sideControllerWidth: CGFloat
    fileprivate var blurView: UIVisualEffectView?
    fileprivate var vibrancyView: UIVisualEffectView?
    
    fileprivate lazy var presentedSideHorizontalPosition: CGFloat = {
        let isRTL = self.view.isRightToLeftLanguage()
        return isRTL ? UIScreen.main.bounds.width : self.sideControllerWidth
    }()
    
    lazy var initialSideHorizontalPosition: CGFloat = {
        let isRTL = self.view.isRightToLeftLanguage()
        return isRTL ? UIScreen.main.bounds.width + self.sideControllerWidth : 0.0
    }()
    
    required public init(frontController: UIViewController, sideController: UIViewController, sideControllerWidth: CGFloat, background: Background) {
        self.frontController = frontController
        self.sideController = sideController
        self.sideControllerWidth = sideControllerWidth
        self.background = background
        self._state = .front
        
        super.init(nibName: nil, bundle: nil)
        
        self.sideContainerViewController.transitioningDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
}

extension SimpleSideController {
    public func showFrontController() {
        self._state = .front
    }
    
    public func showSideController() {
        self._state = .side
    }
    
    public func isPanGestureEnabled() -> Bool {
        return self.panGestureRecognizer?.isEnabled ?? false
    }
    
    public func disablePanGesture() {
        self.panGestureRecognizer?.isEnabled = false
    }
    
    public func enablePanGesture() {
        self.panGestureRecognizer?.isEnabled = true
    }
}

extension SimpleSideController {
    @objc fileprivate func handleTapGesture(gr: UITapGestureRecognizer) {
        switch self._state {
        case .front:
            self._state = .side
        case .side:
            self._state = .front
        case .transitioning:
            break
        }
    }
}

extension SimpleSideController {
    fileprivate func setup() {
        
        self.presentInteractionController = PresentInteractionController(simpleSideController: self)
        self.dismissInteractionController = DismissInteractionController(simpleSideController: self)
        self.tapGestureRecognizer.addTarget(self, action: #selector(handleTapGesture(gr:)))
        self.tapGestureRecognizer.delegate = self
        
        self.addChildViewController(self.frontController)
        self.view.addSubview(self.frontController.view)
        self.frontController.view.frame = self.view.bounds
        self.frontController.didMove(toParentViewController: self)
        
        self.sideContainerViewController.view.frame = CGRect(x: -self.sideControllerWidth, y: 0, width: self.sideControllerWidth, height: UIScreen.main.bounds.height)
        self.sideContainerViewController.modalPresentationStyle = .overCurrentContext
        self.sideContainerViewController.view.addSubview(self.borderView)
        self.constrainBorderView()
        
        self.sideContainerViewController.view.hideShadow(animation: 0.0)
        
        switch self.background {
        case let .translucent(color, style):
            self.sideContainerViewController.view.backgroundColor = color
            let blurEffect = UIBlurEffect(style: style)
            self.blurView = UIVisualEffectView(effect: blurEffect)
            self.sideContainerViewController.view.insertSubview(self.blurView!, at: 0)
            self.pinIntoSideContainer(view: self.blurView!)
            self.sideContainerViewController.addChildViewController(self.sideController)
            self.blurView?.contentView.addSubview(self.sideController.view)
            self.pinIntoSuperView(view: self.sideController.view)
            self.sideController.didMove(toParentViewController: self)
        case let .vibrant(color, style):
            self.sideContainerViewController.view.backgroundColor = color
            let blurEffect = UIBlurEffect(style: style)
            self.blurView = UIVisualEffectView(effect: blurEffect)
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            self.vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            self.sideContainerViewController.view.insertSubview(self.blurView!, at: 0)
            self.pinIntoSideContainer(view: self.blurView!)
            self.sideContainerViewController.addChildViewController(self.sideController)
            self.blurView?.contentView.addSubview(self.vibrancyView!)
            self.pinIntoSuperView(view: self.vibrancyView!)
            self.vibrancyView?.contentView.addSubview(self.sideController.view)
            self.pinIntoSuperView(view: self.sideController.view)
            self.sideController.didMove(toParentViewController: self.sideContainerViewController)
        case let .opaque(color, shadow):
            self.sideContainerViewController.view.backgroundColor = color
            self.shadow = shadow
            self.sideContainerViewController.addChildViewController(self.sideController)
            self.sideContainerViewController.view.addSubview(self.sideController.view)
            self.pinIntoSideContainer(view: self.sideController.view)
            self.sideController.didMove(toParentViewController: self.sideContainerViewController)
        case let .dim(color, _):
            self.sideContainerViewController.view.backgroundColor = color
            self.sideContainerViewController.addChildViewController(self.sideController)
            self.sideContainerViewController.view.addSubview(self.sideController.view)
            self.pinIntoSideContainer(view: self.sideController.view)
            self.sideController.didMove(toParentViewController: self.sideContainerViewController)
        }
    }
}

extension SimpleSideController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = gestureRecognizer.view else { return false }
        
        switch gestureRecognizer {
        case let gr as UITapGestureRecognizer:
            return gr == self.tapGestureRecognizer &&
                !self.sideContainerViewController.view.frame.contains(touch.location(in: view))
        case let gr as UIPanGestureRecognizer:
            return gr.translation(in: view).x > gr.translation(in: view).y
        default:
            return false
        }
    }
}

//MARK: Utilities
//extension SimpleSideController {
//    fileprivate func performTransition(to state: Presenting) {
//        switch state {
//        case .front:
//            self.view.layoutIfNeeded()
//            self.sideContainerHorizontalConstraint?.constant = self.initialSideHorizontalPosition
//            self.sideContainerView.hideShadow()
//            UIView.animate(withDuration: 0.25,
//                           delay: 0.0,
//                           options: .curveEaseIn,
//                           animations: {
//                            self.view.layoutIfNeeded()
//            }) { finished in
//                if finished {
//                    self.delegate?.sideController(self, didChangeTo: state)
//                }
//            }
//        case .side:
//            self.view.layoutIfNeeded()
//            self.sideContainerHorizontalConstraint?.constant = self.presentedSideHorizontalPosition
//            if let opacity = self.shadow?.opacity {
//                self.sideContainerView.displayShadow(opacity: opacity)
//            }
//            UIView.animate(withDuration: 0.25,
//                           delay: 0.0,
//                           options: .curveEaseOut,
//                           animations: {
//                            self.view.layoutIfNeeded()
//            }) { finished in
//                if finished {
//                    self.delegate?.sideController(self, didChangeTo: state)
//                }
//            }
//        case .transitioning:
//            break
//        }
//    }
//}

extension SimpleSideController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presentAnimationController = PresentAnimationController(simpleSideController: self)
        return self.presentAnimationController
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.dismissAnimationController  = DismissAnimationController(simpleSideController: self)
        return self.dismissAnimationController
    }
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interactionController = self.presentInteractionController else { return nil }
        return interactionController.isInProgress ? interactionController : nil
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interactionController = self.dismissInteractionController else { return nil }
        return interactionController.isInProgress ? interactionController : nil
    }
}
