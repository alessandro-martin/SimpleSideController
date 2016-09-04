//
//  AutolayoutHelpers.swift
//  SimpleSideController
//
//  Created by Alessandro Martin on 04/09/16.
//  Copyright © 2016 Alessandro Martin. All rights reserved.
//

import UIKit

extension SimpleSideController {
    func pinIntoSideContainer(view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: view,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: self.sideContainerViewController.view,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 0.0)
        let bottom = NSLayoutConstraint(item: view,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: self.sideContainerViewController.view,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
        let leading = NSLayoutConstraint(item: view,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self.sideContainerViewController.view,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 0.0)
        let trailing = NSLayoutConstraint(item: view,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: self.borderView,
                                          attribute: .leading,
                                          multiplier: 1.0,
                                          constant: 0.0)
        NSLayoutConstraint.activate([top, bottom, leading, trailing])
    }
    
    func pinIntoSuperView(view : UIView) {
        guard let superView = view.superview else { fatalError("\(view) does not have a superView!") }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: view,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: superView,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 0.0)
        let bottom = NSLayoutConstraint(item: view,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: superView,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
        let leading = NSLayoutConstraint(item: view,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: superView,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 0.0)
        let trailing = NSLayoutConstraint(item: view,
                                          attribute: .trailing,
                                          relatedBy: .equal,
                                          toItem: superView,
                                          attribute: .trailing,
                                          multiplier: 1.0,
                                          constant: 0.0)
        NSLayoutConstraint.activate([top, bottom, leading, trailing])
    }
    
    func constrainBorderView() {
        self.borderView.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: self.borderView,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: self.sideContainerViewController.view,
                                     attribute: .top,
                                     multiplier: 1.0,
                                     constant: 0.0)
        let bottom = NSLayoutConstraint(item: self.borderView,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: self.sideContainerViewController.view,
                                        attribute: .bottom,
                                        multiplier: 1.0,
                                        constant: 0.0)
        self.borderWidthConstraint = NSLayoutConstraint(item: self.borderView,
                                                        attribute: .width,
                                                        relatedBy: .equal,
                                                        toItem: nil,
                                                        attribute: .notAnAttribute,
                                                        multiplier: 1.0,
                                                        constant: self.border?.thickness ?? 0.0)
        let side = NSLayoutConstraint(item: self.borderView,
                                      attribute: .trailing,
                                      relatedBy: .equal,
                                      toItem: self.sideContainerViewController.view,
                                      attribute: .trailing,
                                      multiplier: 1.0,
                                      constant: 0.0)
        NSLayoutConstraint.activate([top, bottom, self.borderWidthConstraint!, side])
    }
}
